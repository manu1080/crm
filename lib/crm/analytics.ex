defmodule Crm.Analytics do
  @moduledoc """
  Analytics context for generating sales dashboard metrics.
  """

  import Ecto.Query
  alias Crm.Repo
  alias Crm.Sales.{Lead, Activity, Stage}
  alias Crm.Settings.Source

  defp maybe_filter_owner(query, nil), do: query
  defp maybe_filter_owner(query, owner), do: where(query, [l], l.owner == ^owner)

  defp maybe_filter_source(query, nil), do: query
  defp maybe_filter_source(query, source_id), do: where(query, [l], l.source_id == ^source_id)

  # Versiones para queries con joins donde Lead es el segundo binding
  defp maybe_filter_owner_joined(query, nil), do: query
  defp maybe_filter_owner_joined(query, owner), do: where(query, [_, l], l.owner == ^owner)

  defp maybe_filter_source_joined(query, nil), do: query
  defp maybe_filter_source_joined(query, source_id), do: where(query, [_, l], l.source_id == ^source_id)

  @doc """
  Get leads created per day for the last N days.
  Returns a list of {date, count} tuples.
  Accepts optional filters: owner, source_id.
  """
  def leads_per_day(days \\ 30, opts \\ []) do
    owner = Keyword.get(opts, :owner)
    source_id = Keyword.get(opts, :source_id)

    from(l in Lead,
      where: l.inserted_at >= ago(^days, "day"),
      group_by: fragment("DATE(?)", l.inserted_at),
      select: {fragment("DATE(?)", l.inserted_at), count(l.id)},
      order_by: [asc: fragment("DATE(?)", l.inserted_at)]
    )
    |> maybe_filter_owner(owner)
    |> maybe_filter_source(source_id)
    |> Repo.all()
    |> Enum.map(fn {date, count} ->
      {Date.to_string(date), count}
    end)
  end

  @doc """
  Get conversion metrics by stage.
  Returns a list of {stage_name, count, percentage} tuples.
  Accepts optional filters: owner, source_id.
  """
  def conversion_by_stage(opts \\ []) do
    owner = Keyword.get(opts, :owner)
    source_id = Keyword.get(opts, :source_id)

    total_query = from(l in Lead)
    total_query = maybe_filter_owner(total_query, owner)
    total_query = maybe_filter_source(total_query, source_id)
    total_leads = Repo.aggregate(total_query, :count, :id)

    from(s in Stage,
      left_join: l in Lead,
      on: l.stage_id == s.id,
      group_by: [s.id, s.label, s.order],
      select: {s.label, count(l.id)},
      order_by: s.order
    )
    |> maybe_filter_owner_joined(owner)
    |> maybe_filter_source_joined(source_id)
    |> Repo.all()
    |> Enum.map(fn {stage, count} ->
      percentage = if total_leads > 0, do: Float.round(count / total_leads * 100, 1), else: 0.0
      {stage, count, percentage}
    end)
  end

  @doc """
  Get conversion metrics by source.
  Returns a list of {source_name, total_leads, won_leads, win_rate} tuples.
  Accepts optional filters: owner.
  """
  def conversion_by_source(opts \\ []) do
    owner = Keyword.get(opts, :owner)
    won_stage = Repo.one(from s in Stage, where: s.name == "won", select: s.id)

    from(src in Source,
      left_join: l in Lead,
      on: l.source_id == src.id,
      group_by: [src.id, src.name],
      select: {
        src.name,
        count(l.id),
        fragment("COUNT(CASE WHEN ? = ? THEN 1 END)", l.stage_id, ^won_stage)
      },
      order_by: [desc: count(l.id)]
    )
    |> maybe_filter_owner_joined(owner)
    |> Repo.all()
    |> Enum.map(fn {name, total, won} ->
      win_rate = if total > 0, do: Float.round(won / total * 100, 1), else: 0.0
      {name, total, won, win_rate}
    end)
  end

  @doc """
  Get activity count per owner/user.
  Returns a list of {owner, activity_count} tuples.
  Accepts optional filters: owner, source_id.
  """
  def activities_per_user(opts \\ []) do
    owner = Keyword.get(opts, :owner)
    source_id = Keyword.get(opts, :source_id)

    from(a in Activity,
      join: l in Lead,
      on: a.lead_id == l.id,
      where: not is_nil(l.owner),
      group_by: l.owner,
      select: {l.owner, count(a.id)},
      order_by: [desc: count(a.id)]
    )
    |> maybe_filter_owner_joined(owner)
    |> maybe_filter_source_joined(source_id)
    |> Repo.all()
  end

  @doc """
  Calculate win rate.
  Returns a map with total leads, won leads, and win rate percentage.
  Accepts optional filters: owner, source_id.
  """
  def win_rate(opts \\ []) do
    owner = Keyword.get(opts, :owner)
    source_id = Keyword.get(opts, :source_id)

    # Total leads with filters
    total_query = from(l in Lead)
    total_query = maybe_filter_owner(total_query, owner)
    total_query = maybe_filter_source(total_query, source_id)
    total = Repo.aggregate(total_query, :count, :id)

    # Won leads with filters
    won_query = from(l in Lead,
      join: s in Stage,
      on: l.stage_id == s.id,
      where: s.name == "won",
      select: count(l.id)
    )

    won_query = maybe_filter_owner(won_query, owner)
    won_query = maybe_filter_source(won_query, source_id)
    won = Repo.one(won_query)

    win_rate = if total > 0, do: Float.round(won / total * 100, 1), else: 0.0

    %{
      total: total,
      won: won,
      win_rate: win_rate
    }
  end

  @doc """
  Get active vs inactive leads based on recent activity.
  A lead is considered active if it has activity in the last N days.
  Accepts optional filters: owner, source_id.
  """
  def active_vs_inactive_leads(days \\ 30, opts \\ []) do
    owner = Keyword.get(opts, :owner)
    source_id = Keyword.get(opts, :source_id)
    cutoff_date = DateTime.utc_now() |> DateTime.add(-days * 24 * 3600, :second)

    active_query = from(l in Lead,
      where: not is_nil(l.last_activity_at) and l.last_activity_at >= ^cutoff_date,
      select: count(l.id)
    )

    active_query = maybe_filter_owner(active_query, owner)
    active_query = maybe_filter_source(active_query, source_id)
    active = Repo.one(active_query)

    inactive_query = from(l in Lead,
      where: is_nil(l.last_activity_at) or l.last_activity_at < ^cutoff_date,
      select: count(l.id)
    )

    inactive_query = maybe_filter_owner(inactive_query, owner)
    inactive_query = maybe_filter_source(inactive_query, source_id)
    inactive = Repo.one(inactive_query)

    total = active + inactive

    %{
      active: active,
      inactive: inactive,
      total: total,
      active_percentage: if(total > 0, do: Float.round(active / total * 100, 1), else: 0.0)
    }
  end

  @doc """
  Get all dashboard metrics at once.
  Accepts options: days, owner, source_id.
  """
  def dashboard_metrics(opts \\ []) do
    days = Keyword.get(opts, :days, 30)
    filter_opts = Keyword.take(opts, [:owner, :source_id])

    %{
      leads_per_day: leads_per_day(days, filter_opts),
      conversion_by_stage: conversion_by_stage(filter_opts),
      conversion_by_source: conversion_by_source(filter_opts),
      activities_per_user: activities_per_user(filter_opts),
      win_rate: win_rate(filter_opts),
      active_vs_inactive: active_vs_inactive_leads(days, filter_opts)
    }
  end

  @doc """
  Subscribe to dashboard updates.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Crm.PubSub, "dashboard")
  end

  @doc """
  Broadcast dashboard update event.
  """
  def broadcast_update do
    Phoenix.PubSub.broadcast(Crm.PubSub, "dashboard", :dashboard_updated)
  end
end
