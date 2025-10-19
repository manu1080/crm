defmodule Crm.Repo.Migrations.AddRolePermissions do
  use Ecto.Migration

  def change do
    create table(:role_permissions) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :resource, :string, null: false
      add :action, :string, null: false
      add :scope, :string, default: "all"

      timestamps()
    end

    create index(:role_permissions, [:role_id])
    create unique_index(:role_permissions, [:role_id, :resource, :action])
  end
end
