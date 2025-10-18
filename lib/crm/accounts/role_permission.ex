defmodule Crm.Accounts.RolePermission do
  @moduledoc """
  Schema for role permissions.

  Each permission defines what actions a role can perform on a resource.

  ## Scopes
  - `all`: Can perform action on all records
  - `own`: Can only perform action on own records
  - `limited`: Has limited access (specific to resource/action)
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "role_permissions" do
    field :resource, :string
    field :action, :string
    field :scope, :string, default: "all"

    belongs_to :role, Crm.Accounts.Role

    timestamps()
  end
end
