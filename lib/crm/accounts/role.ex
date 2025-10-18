defmodule Crm.Accounts.Role do
  use Ecto.Schema

  schema "roles" do
    field :name, :string
    field :label, :string
    field :description, :string

    has_many :users, Crm.Accounts.User
    has_many :permissions, Crm.Accounts.RolePermission

    timestamps()
  end
end
