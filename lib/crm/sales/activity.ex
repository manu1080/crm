defmodule Crm.Sales.Activity do
  @moduledoc """
  Schema for lead activities.
  Records all interactions and actions performed on a lead.
  Automatically manages stage transitions based on activity type.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          lead_id: integer(),
          type: String.t(),
          description: String.t() | nil,
          stage_change_from_id: integer() | nil,
          stage_change_to_id: integer() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @activity_types ~w(
    call_logged
    meeting_completed
    offer_sent
    offer_accepted
    deposit_received
    notary_scheduled
    contract_signed
    offer_rejected
    reminder_set
    note_added
    lead_lost
    lead_reactivated
    email_sent
    whatsapp_sent
  )

  schema "activities" do
    field :type, :string
    field :description, :string

    belongs_to :lead, Crm.Sales.Lead
    belongs_to :stage_change_from, Crm.Sales.Stage
    belongs_to :stage_change_to, Crm.Sales.Stage

    timestamps(type: :utc_datetime)
  end

  @doc """
  Returns the list of valid activity types.
  """
  def activity_types, do: @activity_types

  @doc """
  Changeset for creating an activity.
  """
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:lead_id, :type, :description, :stage_change_from_id, :stage_change_to_id])
    |> validate_required([:lead_id, :type])
    |> validate_inclusion(:type, @activity_types)
    |> validate_length(:description, max: 500)
    |> foreign_key_constraint(:lead_id)
    |> foreign_key_constraint(:stage_change_from_id)
    |> foreign_key_constraint(:stage_change_to_id)
  end

  @doc """
  Returns a human-readable label for an activity type.
  """
  def type_label(type) do
    case type do
      "call_logged" -> "Call Logged"
      "meeting_completed" -> "Meeting Completed"
      "offer_sent" -> "Offer Sent"
      "offer_accepted" -> "Offer Accepted"
      "deposit_received" -> "Deposit Received"
      "notary_scheduled" -> "Notary Scheduled"
      "contract_signed" -> "Contract Signed"
      "offer_rejected" -> "Offer Rejected"
      "reminder_set" -> "Reminder Set"
      "note_added" -> "Note Added"
      "lead_lost" -> "Lead Lost"
      "lead_reactivated" -> "Lead Reactivated"
      "email_sent" -> "Email Sent"
      "whatsapp_sent" -> "WhatsApp Sent"
      _ -> type
    end
  end
end
