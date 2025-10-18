defmodule CrmWeb.AuthorizationHelpers do
  @moduledoc """
  Helper functions for authorization in LiveViews.
  """

  alias Crm.Accounts

  @doc """
  Checks if current user can perform an action on a resource.
  Returns true/false.
  """
  def can?(user, resource, action) do
    Accounts.can?(user, resource, action)
  end

  @doc """
  Gets the permission scope for a user on a resource/action.
  Returns "all", "own", "limited", or nil.
  """
  def permission_scope(user, resource, action) do
    Accounts.permission_scope(user, resource, action)
  end

  @doc """
  Checks if user can access specific data based on their permission scope.
  For "all" scope: returns true
  For "own" scope: returns true if data.owner == user.email
  For "limited" scope: custom logic per resource
  """
  def can_access?(user, resource, action, data) do
    Accounts.can_access?(user, resource, action, data)
  end
end
