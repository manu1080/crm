defmodule CrmWeb.UserRegistrationLive do
  use CrmWeb, :live_view

  alias Crm.Accounts
  alias Crm.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen gh-canvas flex items-center justify-center px-6 py-8">
      <div class="gh-form-container max-w-md w-full">
        <div class="text-center mb-8">
          <h1 class="gh-form-title">Register for an account</h1>

          <p class="gh-text-secondary mt-2">
            Already registered? <.link navigate={~p"/login"} class="gh-link">Sign in</.link>
            to your account now.
          </p>
        </div>

        <.form
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/login?_action=registered"}
          method="post"
        >
          <div :if={@check_errors} class="gh-alert gh-alert-error mb-4">
            <.icon name="hero-exclamation-circle" class="w-5 h-5" />
            <span>Oops, something went wrong! Please check the errors below.</span>
          </div>

          <div class="gh-form-group">
            <label class="gh-form-label gh-form-label-required">Name</label>
            <.input
              field={@form[:name]}
              type="text"
              class="gh-form-input"
              placeholder="Your full name"
              required
            />
          </div>

          <div class="gh-form-group">
            <label class="gh-form-label gh-form-label-required">Email</label>
            <.input
              field={@form[:email]}
              type="email"
              class="gh-form-input"
              placeholder="your@email.com"
              required
            />
          </div>

          <div class="gh-form-group">
            <label class="gh-form-label gh-form-label-required">Password</label>
            <.input
              field={@form[:password]}
              type="password"
              class="gh-form-input"
              placeholder="••••••••"
              required
            />
            <p class="gh-text-tertiary text-xs mt-1">At least 6 characters</p>
          </div>

          <div class="gh-form-group">
            <label class="gh-form-label gh-form-label-required">Role</label>
            <select name="user[role_id]" class="gh-form-input" required>
              <option value="">Select a role</option>
              <%= for role <- @roles do %>
                <option value={role.id} selected={@form[:role_id].value == role.id}>
                  {role.label}
                </option>
              <% end %>
            </select>
            <p class="gh-text-tertiary text-xs mt-1">
              Choose the appropriate role for this user
            </p>
          </div>

          <div class="gh-form-actions">
            <button
              type="submit"
              class="gh-btn gh-btn-primary w-full"
              phx-disable-with="Creating account..."
            >
              Create an account
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    roles = Accounts.list_roles()

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:roles, roles)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        # Successfully registered - no email confirmation needed for now
        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
