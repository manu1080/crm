defmodule Crm.Accounts do
  import Ecto.Query
  alias Crm.Repo
  alias Crm.Accounts.{User, Role, UserToken}

  # Users

  def get_user_by_email(email) do
    User
    |> preload(:role)
    |> Repo.get_by(email: email)
  end

  @doc """
  Verifies a user's password.
  Returns {:ok, user} if valid, {:error, :invalid_credentials} otherwise.
  """
  def verify_user_password(email, password) do
    case get_user_by_email(email) do
      nil ->
        # Run a dummy hash to prevent timing attacks
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  @doc """
  Registers a user.
  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  @doc """
  Delivers user confirmation instructions (placeholder).
  For now, just returns {:ok, user} since we don't have email setup.
  """
  def deliver_user_confirmation_instructions(user, _confirmation_url_fun) do
    # TODO: Implement email sending when Swoosh is configured
    {:ok, user}
  end

  # Roles

  def get_role_by_name(name) do
    Repo.get_by(Role, name: name)
  end

  @doc """
  Lists all roles.
  """
  def list_roles do
    Repo.all(from r in Role, order_by: r.name)
  end

  # Permissions

  @doc """
  Checks if a user can perform an action on a resource.

  ## Examples

      iex> can?(user, "leads", "create")
      true

      iex> can?(user, "activities", "create")
      false
  """
  def can?(%User{} = user, resource, action) do
    user = Repo.preload(user, role: :permissions)

    Enum.any?(user.role.permissions, fn permission ->
      permission.resource == resource && permission.action == action
    end)
  end

  @doc """
  Gets the scope for a user's permission on a resource/action.
  Returns :all, :own, :limited, or nil if no permission.

  ## Examples

      iex> permission_scope(user, "leads", "index")
      :all

      iex> permission_scope(user, "leads", "update")
      :own
  """
  def permission_scope(%User{} = user, resource, action) do
    user = Repo.preload(user, role: :permissions)

    case Enum.find(user.role.permissions, fn permission ->
           permission.resource == resource && permission.action == action
         end) do
      nil -> nil
      permission -> String.to_atom(permission.scope)
    end
  end

  @doc """
  Checks if a user can access a specific record.
  Takes into account the permission scope (all, own, limited).
  """
  def can_access?(%User{} = user, resource, action, record) do
    case permission_scope(user, resource, action) do
      :all -> true
      :own -> owns_record?(user, record)
      # Additional checks can be added per resource
      :limited -> true
      nil -> false
    end
  end

  defp owns_record?(%User{} = user, %{owner: owner}) when is_binary(owner) do
    user.name == owner
  end

  defp owns_record?(%User{} = user, %{user_id: user_id}) do
    user.id == user_id
  end

  defp owns_record?(_, _), do: false

  # Session Tokens

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query) |> Repo.preload(:role)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end
end
