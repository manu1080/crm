defmodule Crm.Repo.Migrations.CreateStages do
  use Ecto.Migration

  def change do
    create table(:stages) do
      add :name, :string, null: false
      add :label, :string, null: false
      add :description, :text
      add :order, :integer, null: false
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:stages, [:name])
  end
end
