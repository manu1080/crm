defmodule CrmWeb.Router do
  use CrmWeb, :router

  import CrmWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CrmWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes (no authentication required)
  scope "/", CrmWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{CrmWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
    end

    post "/login", UserSessionController, :create
  end

  # Protected routes (authentication required)
  scope "/", CrmWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CrmWeb.UserAuth, :ensure_authenticated}],
      layout: {CrmWeb.Layouts, :app} do
      live "/", LeadLive.Index, :index
      live "/leads", LeadLive.Index, :index
      live "/leads/new", LeadLive.Form, :new
      live "/leads/:id", LeadLive.Show, :show
      live "/leads/:id/edit", LeadLive.Form, :edit

      live "/activities/new", ActivityLive.Form, :new

      live "/dashboard", DashboardLive.Index, :index
    end

    # Export routes
    get "/export/leads.csv", ExportController, :leads_csv

    delete "/logout", UserSessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", CrmWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:crm, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CrmWeb.Telemetry
    end
  end
end
