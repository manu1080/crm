defmodule Crm.Repo.Migrations.CreateActivity do
  use Ecto.Migration

  def up do
    # Drop old activities table if exists
    drop_if_exists table(:activities)

    # Create new activities table
    create table(:activities) do
      add :lead_id, references(:leads, on_delete: :delete_all), null: false
      add :type, :string, null: false
      add :description, :text
      add :stage_change_from_id, references(:stages, on_delete: :nilify_all)
      add :stage_change_to_id, references(:stages, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop table(:activities)
  end
end
