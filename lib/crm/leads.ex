defmodule Crm.Leads do
  @moduledoc """
  The Leads context.
  """

  import Ecto.Query, warn: false
  alias Crm.Repo
  alias Crm.Sales.Lead
  alias Crm.Stages

  @doc """
  Returns the list of leads.

  ## Examples

      iex> list_leads()
      [%Lead{}, ...]

  """
  def list_leads do
    Lead
    |> preload([:stage_rel, :source_rel])
    |> Repo.all()
  end

  @doc """
  Returns the list of leads with filters applied.
  Supports filtering by: stage, source, owner, starred

  ## Examples

      iex> list_leads(stage: "new", owner: "john")
      [%Lead{}, ...]

  """
  def list_leads(filters) when is_list(filters) do
    Lead
    |> join(:left, [l], s in assoc(l, :stage_rel))
    |> join(:left, [l], src in assoc(l, :source_rel))
    |> preload([l, s, src], stage_rel: s, source_rel: src)
    |> apply_filters(filters)
    |> Repo.all()
  end

  defp apply_filters(query, []), do: query

  defp apply_filters(query, [{:stage, stage_name} | rest]) do
    query
    |> where([l, s], s.name == ^stage_name)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:source, source_name} | rest]) do
    query
    |> where([l, s, src], src.name == ^source_name)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:owner, owner} | rest]) do
    query
    |> where([l], l.owner == ^owner)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:starred, true} | rest]) do
    query
    |> where([l], l.starred == true)
    |> apply_filters(rest)
  end

  defp apply_filters(query, [{:starred, false} | rest]) do
    apply_filters(query, rest)
  end

  @doc """
  Returns a list of unique owners from all leads.

  ## Examples

      iex> list_unique_owners()
      ["John Doe", "Jane Smith", ...]

  """
  def list_unique_owners do
    Lead
    |> where([l], not is_nil(l.owner))
    |> select([l], l.owner)
    |> distinct(true)
    |> order_by([l], l.owner)
    |> Repo.all()
  end

  @doc """
  Gets a single lead with all associations preloaded.

  Raises `Ecto.NoResultsError` if the Lead does not exist.

  ## Examples

      iex> get_lead!(123)
      %Lead{}

      iex> get_lead!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lead!(id) do
    Lead
    |> preload([:stage_rel, :source_rel, :activities])
    |> Repo.get!(id)
  end

  @doc """
  Creates a lead.

  ## Examples

      iex> create_lead(%{name: "John Doe", email: "john@example.com"})
      {:ok, %Lead{}}

      iex> create_lead(%{name: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_lead(attrs \\ %{}) do
    %Lead{}
    |> Lead.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:lead_created)
  end

  @doc """
  Updates a lead.

  ## Examples

      iex> update_lead(lead, %{name: "Jane Doe"})
      {:ok, %Lead{}}

      iex> update_lead(lead, %{email: nil})
      {:error, %Ecto.Changeset{}}

  """
  def update_lead(%Lead{} = lead, attrs) do
    lead
    |> Lead.changeset(attrs)
    |> Repo.update()
    |> broadcast(:lead_updated)
  end

  @doc """
  Changes the stage of a lead by stage name and updates last_activity_at.

  ## Examples

      iex> change_stage(lead, "qualified")
      {:ok, %Lead{stage_id: 3}}

  """
  def change_stage(%Lead{} = lead, stage_name) when is_binary(stage_name) do
    case Stages.get_stage_by_name(stage_name) do
      nil ->
        {:error, :invalid_stage}

      stage ->
        lead
        |> Lead.changeset(%{
          stage_id: stage.id,
          last_activity_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> Repo.update()
        |> broadcast(:lead_updated)
    end
  end

  def change_stage(_lead, _stage), do: {:error, :invalid_stage}

  @doc """
  Toggles the starred status of a lead.

  ## Examples

      iex> toggle_starred(lead)
      {:ok, %Lead{starred: true}}

  """
  def toggle_starred(%Lead{} = lead) do
    lead
    |> Lead.starred_changeset(!lead.starred)
    |> Repo.update()
    |> broadcast(:lead_updated)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lead changes.

  ## Examples

      iex> change_lead(lead)
      %Ecto.Changeset{data: %Lead{}}

  """
  def change_lead(%Lead{} = lead, attrs \\ %{}) do
    Lead.changeset(lead, attrs)
  end

  @doc """
  Returns a list of unique owners from all leads.

  ## Examples

      iex> list_owners()
      ["Ana García", "Carlos López", ...]

  """
  def list_owners do
    Lead
    |> select([l], l.owner)
    |> where([l], not is_nil(l.owner))
    |> distinct(true)
    |> order_by([l], asc: l.owner)
    |> Repo.all()
  end

  ## PubSub Broadcasting

  @doc """
  Subscribes to lead updates.
  Call this in your LiveView mount to receive real-time updates.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(Crm.PubSub, "leads")
  end

  defp broadcast({:ok, lead}, event) do
    Phoenix.PubSub.broadcast(Crm.PubSub, "leads", {event, lead})
    {:ok, lead}
  end

  defp broadcast({:error, _reason} = error, _event), do: error
end
