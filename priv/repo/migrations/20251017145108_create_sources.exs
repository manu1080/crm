defmodule Crm.Repo.Migrations.CreateSources do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:sources, [:name])
  end
end
