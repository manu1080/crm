defmodule Crm.Activities do
  @moduledoc """
  The Activities context.
  Manages lead activities and automatic stage transitions.

  ## Real-time Updates

  This context automatically broadcasts lead updates via Phoenix.PubSub
  whenever an activity is created. This ensures that:

  - The Kanban board updates in real-time when activities are added
  - Stage transitions are reflected immediately across all connected clients
  - The `last_activity_at` timestamp updates are broadcast instantly

  LiveViews that subscribe to "leads" topic via `Crm.Leads.subscribe/0`
  will receive `{:lead_updated, lead}` messages automatically.

  ## Automatic Stage Transitions

  Certain activity types trigger automatic stage transitions:

  - `meeting_completed` (when in "contacted") → "qualified"
  - `offer_sent` → "meeting"
  - `offer_accepted` → "deposit"
  - `deposit_received` → "notary"
  - `notary_scheduled` → "management_contract"
  - `contract_signed` → "won"
  - `offer_rejected` → "lost"
  - `lead_lost` → "lost"
  - `lead_reactivated` → "contacted"
  """

  import Ecto.Query, warn: false
  alias Crm.Repo
  alias Crm.Sales.{Activity, Lead}
  alias Ecto.Multi

  @doc """
  Creates an activity and automatically transitions the lead stage if needed.
  Uses Ecto.Multi to ensure atomicity.

  ## Examples

      iex> create_activity(%{"type" => "call_logged", "lead_id" => 1})
      {:ok, %Activity{}}

      iex> create_activity(%{"type" => "meeting_completed", "lead_id" => 1})
      {:ok, %Activity{}} # Also transitions stage from contacted -> qualified

  """
  def create_activity(attrs \\ %{}) do
    lead_id = attrs["lead_id"]
    type = attrs["type"]

    lead = if lead_id, do: Repo.get!(Lead, lead_id) |> Repo.preload(:stage_rel), else: nil

    Multi.new()
    |> Multi.run(:stage_change, fn repo, _changes ->
      handle_stage_transition(type, lead, repo)
    end)
    |> Multi.insert(:activity, fn %{stage_change: stage_info} ->
      attrs_with_stage = merge_stage_changes(attrs, stage_info)

      %Activity{}
      |> Activity.changeset(attrs_with_stage)
    end)
    |> Multi.run(:update_lead_activity_time, fn repo, %{activity: _activity} ->
      if lead do
        lead
        |> Ecto.Changeset.change(%{
          last_activity_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> repo.update()
      else
        {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{activity: activity, update_lead_activity_time: updated_lead}} ->
        # Broadcast lead update to all connected clients
        broadcast_lead_update(updated_lead)
        {:ok, activity}

      {:error, :activity, changeset, _} ->
        {:error, changeset}

      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking activity changes.

  ## Examples

      iex> change_activity(activity)
      %Ecto.Changeset{data: %Activity{}}

  """
  def change_activity(%Activity{} = activity, attrs \\ %{}) do
    Activity.changeset(activity, attrs)
  end

  defp broadcast_lead_update(nil), do: :ok

  defp broadcast_lead_update(lead) do
    Phoenix.PubSub.broadcast(
      Crm.PubSub,
      "leads",
      {:lead_updated, lead}
    )
  end

  defp handle_stage_transition(_type, nil, _repo), do: {:ok, %{from: nil, to: nil}}

  defp handle_stage_transition(type, lead, repo) do
    current_stage = lead.stage_rel

    case auto_stage_transition(type, current_stage.name) do
      nil ->
        {:ok, %{from: nil, to: nil}}

      target_stage_name ->
        target_stage = repo.get_by!(Crm.Sales.Stage, name: target_stage_name)

        # Update lead's stage
        lead
        |> Ecto.Changeset.change(%{stage_id: target_stage.id})
        |> repo.update()

        {:ok, %{from: current_stage.id, to: target_stage.id}}
    end
  end

  defp merge_stage_changes(attrs, %{from: nil, to: nil}), do: attrs

  defp merge_stage_changes(attrs, %{from: from_id, to: to_id}) do
    attrs
    |> Map.put("stage_change_from_id", from_id)
    |> Map.put("stage_change_to_id", to_id)
  end

  defp auto_stage_transition(activity_type, current_stage_name) do
    case activity_type do
      "meeting_completed" when current_stage_name == "contacted" ->
        "qualified"

      "offer_sent" ->
        "meeting"

      "offer_accepted" ->
        "deposit"

      "deposit_received" ->
        "notary"

      "notary_scheduled" ->
        "management_contract"

      "contract_signed" ->
        "won"

      "offer_rejected" ->
        "lost"

      "lead_lost" ->
        "lost"

      "lead_reactivated" ->
        "contacted"

      _ ->
        nil
    end
  end
end
