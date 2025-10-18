defmodule Crm.Sales.Stage do
  @moduledoc """
  Schema for pipeline stages.
  Represents the different stages in the sales funnel.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          label: String.t(),
          description: String.t() | nil,
          order: integer(),
          active: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "stages" do
    field :name, :string
    field :label, :string
    field :description, :string
    field :order, :integer
    field :active, :boolean, default: true

    has_many :leads, Crm.Sales.Lead

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a stage.
  """
  def changeset(stage, attrs) do
    stage
    |> cast(attrs, [:name, :label, :description, :order, :active])
    |> validate_required([:name, :label, :order])
    |> validate_format(:name, ~r/^[a-z_]+$/, message: "must be lowercase with underscores only")
    |> validate_number(:order, greater_than_or_equal_to: 0)
    |> unique_constraint(:name)
    |> unique_constraint(:order)
  end
end
