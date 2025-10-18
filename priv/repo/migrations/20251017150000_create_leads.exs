defmodule Crm.Repo.Migrations.CreateLeads do
  use Ecto.Migration

  def change do
    create table(:leads) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :source_id, references(:sources, on_delete: :restrict)
      add :stage_id, references(:stages, on_delete: :restrict)
      add :owner, :string
      add :starred, :boolean, default: false, null: false
      add :budget, :integer
      add :last_activity_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:leads, [:email])
  end
end
