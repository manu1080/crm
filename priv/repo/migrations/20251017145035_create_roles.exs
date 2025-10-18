defmodule Crm.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :label, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:roles, [:name])
  end
end
