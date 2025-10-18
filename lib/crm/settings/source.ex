defmodule Crm.Settings.Source do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sources" do
    field :name, :string
    field :description, :string

    has_many :leads, Crm.Sales.Lead, foreign_key: :source_id

    timestamps()
  end

  @doc """
  Changeset for creating or updating a source.
  """
  def changeset(source, attrs) do
    source
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[a-z_]+$/)
    |> unique_constraint(:name)
  end
end
