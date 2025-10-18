defmodule CrmWeb.UserLoginLive do
  use CrmWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen gh-canvas flex items-center justify-center px-6 py-8">
      <div class="gh-form-container max-w-md w-full">
        <div class="text-center mb-8">
          <h1 class="gh-form-title">Sign in to CRM</h1>
          
          <p class="gh-text-secondary mt-2">
            Don't have an account? <.link navigate={~p"/register"} class="gh-link">Sign up</.link>
            for an account now.
          </p>
        </div>
        
        <.form for={@form} id="login_form" action={~p"/login"} phx-update="ignore">
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
          </div>
          
          <div class="gh-form-group">
            <label class="flex items-center gap-2 cursor-pointer">
              <.input field={@form[:remember_me]} type="checkbox" class="gh-checkbox" />
              <span class="gh-text-secondary text-sm">Keep me logged in</span>
            </label>
          </div>
          
          <div class="gh-form-actions">
            <button
              type="submit"
              class="gh-btn gh-btn-primary w-full"
              phx-disable-with="Signing in..."
            >
              Sign in →
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
