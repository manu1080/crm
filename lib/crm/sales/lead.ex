defmodule Crm.Sales.Lead do
  @moduledoc """
  Schema for investment leads in the CRM system.
  Represents potential investors with their profile and pipeline stage.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          email: String.t(),
          phone: String.t() | nil,
          owner: String.t() | nil,
          starred: boolean(),
          budget: integer() | nil,
          last_activity_at: DateTime.t() | nil,
          stage_id: integer() | nil,
          source_id: integer() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @stages ~w(new contacted qualified meeting negotiation deposit notary management_contract won lost)

  schema "leads" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :owner, :string
    field :starred, :boolean, default: false
    field :budget, :integer
    field :last_activity_at, :utc_datetime

    belongs_to :stage_rel, Crm.Sales.Stage, foreign_key: :stage_id
    belongs_to :source_rel, Crm.Settings.Source, foreign_key: :source_id
    has_many :activities, Crm.Sales.Activity

    timestamps(type: :utc_datetime)
  end

  @doc """
  Returns the list of valid stages.
  """
  def stages, do: @stages

  @doc """
  Changeset for creating or updating a lead with basic information.
  """
  def changeset(lead, attrs) do
    lead
    |> cast(attrs, [
      :name,
      :email,
      :phone,
      :owner,
      :starred,
      :budget,
      :last_activity_at,
      :source_id,
      :stage_id
    ])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
    |> validate_format(:phone, ~r/^\+\d{1,15}$/,
      message: "must start with + and contain only numbers (e.g., +34600000000)"
    )
    |> validate_number(:budget, greater_than: 0)
    |> unique_constraint(:email)
    |> foreign_key_constraint(:stage_id)
    |> foreign_key_constraint(:source_id)
  end

  @doc """
  Changeset for toggling the starred flag.
  """
  def starred_changeset(lead, starred) when is_boolean(starred) do
    change(lead, starred: starred)
  end

  @doc """
  Changeset for updating last activity timestamp.
  Called automatically when activities are logged.
  """
  def touch_activity_changeset(lead) do
    change(lead, last_activity_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

  @doc """
  Validates that Won stage has minimum required data.
  Checks against stage_id instead of the old stage string field.
  """
  def validate_won_requirements(changeset, won_stage_id) do
    if get_field(changeset, :stage_id) == won_stage_id do
      validate_required(changeset, [:budget], message: "is required when marking lead as Won")
    else
      changeset
    end
  end
end
