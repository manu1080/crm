defmodule Crm.Repo.Migrations.AddRolePermissions do
  use Ecto.Migration
  import Ecto.Query

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

    # Seed initial permissions
    flush()

    # Get role IDs
    admin_id = repo().one!(from(r in "roles", where: r.name == "admin", select: r.id))
    sales_id = repo().one!(from(r in "roles", where: r.name == "sales", select: r.id))
    marketing_id = repo().one!(from(r in "roles", where: r.name == "marketing", select: r.id))
    capture_id = repo().one!(from(r in "roles", where: r.name == "capture", select: r.id))

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    # Admin permissions - full access to everything
    admin_permissions = [
      # Leads
      %{
        role_id: admin_id,
        resource: "leads",
        action: "index",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "leads",
        action: "show",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "leads",
        action: "create",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "leads",
        action: "update",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "leads",
        action: "delete",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "leads",
        action: "export",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      # Activities
      %{
        role_id: admin_id,
        resource: "activities",
        action: "create",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "activities",
        action: "update",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: admin_id,
        resource: "activities",
        action: "delete",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      # Dashboard
      %{
        role_id: admin_id,
        resource: "dashboard",
        action: "view",
        scope: "all",
        inserted_at: now,
        updated_at: now
      }
    ]

    # Sales permissions - same as admin
    sales_permissions = [
      # Leads
      %{
        role_id: sales_id,
        resource: "leads",
        action: "index",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "leads",
        action: "show",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "leads",
        action: "create",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "leads",
        action: "update",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "leads",
        action: "delete",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "leads",
        action: "export",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      # Activities
      %{
        role_id: sales_id,
        resource: "activities",
        action: "create",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "activities",
        action: "update",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: sales_id,
        resource: "activities",
        action: "delete",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      # Dashboard
      %{
        role_id: sales_id,
        resource: "dashboard",
        action: "view",
        scope: "all",
        inserted_at: now,
        updated_at: now
      }
    ]

    # Marketing permissions - read-only mostly
    marketing_permissions = [
      # Leads - view and create only
      %{
        role_id: marketing_id,
        resource: "leads",
        action: "index",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: marketing_id,
        resource: "leads",
        action: "show",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: marketing_id,
        resource: "leads",
        action: "create",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: marketing_id,
        resource: "leads",
        action: "export",
        scope: "all",
        inserted_at: now,
        updated_at: now
      },
      # Dashboard - limited metrics
      %{
        role_id: marketing_id,
        resource: "dashboard",
        action: "view",
        scope: "limited",
        inserted_at: now,
        updated_at: now
      }
    ]

    # Capture permissions - own leads only
    capture_permissions = [
      # Leads - own only
      %{
        role_id: capture_id,
        resource: "leads",
        action: "index",
        scope: "own",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: capture_id,
        resource: "leads",
        action: "show",
        scope: "own",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: capture_id,
        resource: "leads",
        action: "create",
        scope: "own",
        inserted_at: now,
        updated_at: now
      },
      %{
        role_id: capture_id,
        resource: "leads",
        action: "update",
        scope: "own",
        inserted_at: now,
        updated_at: now
      }
    ]

    # Insert all permissions
    repo().insert_all("role_permissions", admin_permissions)
    repo().insert_all("role_permissions", sales_permissions)
    repo().insert_all("role_permissions", marketing_permissions)
    repo().insert_all("role_permissions", capture_permissions)
  end
end
