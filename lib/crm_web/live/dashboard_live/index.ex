defmodule CrmWeb.DashboardLive.Index do
  use CrmWeb, :live_view

  alias Crm.Analytics
  alias Crm.Leads
  alias Contex.{BarChart, Dataset, Plot}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Analytics.subscribe()
      Leads.subscribe()
    end

    sources = Crm.Settings.list_sources()
    owners = Crm.Leads.list_unique_owners()

    socket =
      socket
      |> assign(:sources, sources)
      |> assign(:owners, owners)
      |> assign(:filters, default_filters())
      |> load_metrics()

    {:ok, socket}
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    updated_filters = %{
      date_range: Map.get(filters, "date_range", "30"),
      owner: Map.get(filters, "owner", "all"),
      source: Map.get(filters, "source", "all")
    }

    {:noreply, socket |> assign(:filters, updated_filters) |> load_metrics()}
  end

  @impl true
  def handle_info(:dashboard_updated, socket) do
    {:noreply, load_metrics(socket)}
  end

  @impl true
  def handle_info({:lead_created, _lead}, socket) do
    {:noreply, load_metrics(socket)}
  end

  @impl true
  def handle_info({:lead_updated, _lead}, socket) do
    {:noreply, load_metrics(socket)}
  end

  @impl true
  def handle_info({:activity_created, _activity}, socket) do
    {:noreply, load_metrics(socket)}
  end

  defp default_filters do
    %{
      date_range: "30",
      owner: "all",
      source: "all"
    }
  end

  defp load_metrics(socket) do
    filters = socket.assigns[:filters] || default_filters()
    days = String.to_integer(filters.date_range)

    metrics =
      Analytics.dashboard_metrics(
        days: days,
        owner: if(filters.owner == "all", do: nil, else: filters.owner),
        source_id: if(filters.source == "all", do: nil, else: String.to_integer(filters.source))
      )

    socket
    |> assign(:metrics, metrics)
    |> assign(:page_title, "Sales Dashboard")
  end

  # Chart rendering functions with GitHub theme colors
  defp render_leads_per_day_chart(data) do
    chart_data = Dataset.new(data, ["Date", "Leads"])

    chart =
      BarChart.new(chart_data,
        colour_palette: ["c9d1d9"],
        axis_label_rotation: 45,
        mapping: %{category_col: "Date", value_cols: ["Leads"]}
      )

    Plot.new(600, 400, chart)
    |> Plot.titles("", "")
    |> Plot.axis_labels("", "Leads")
    |> Plot.to_svg()
    |> raw()
  end

  defp render_conversion_by_stage_chart(data) do
    # Transform data to just stage and count
    chart_data = Enum.map(data, fn {stage, count, _percentage} -> [stage, count] end)
    dataset = Dataset.new(chart_data, ["Stage", "Leads"])

    chart =
      BarChart.new(dataset,
        colour_palette: ["c9d1d9"],
        mapping: %{category_col: "Stage", value_cols: ["Leads"]}
      )

    Plot.new(600, 400, chart)
    |> Plot.titles("", "")
    |> Plot.axis_labels("", "Leads")
    |> Plot.to_svg()
    |> raw()
  end

  defp render_conversion_by_source_chart(data) do
    # Transform data to source and total leads
    chart_data =
      Enum.map(data, fn {source, total, _won, _rate} ->
        [String.capitalize(source), total]
      end)

    dataset = Dataset.new(chart_data, ["Source", "Leads"])

    chart =
      BarChart.new(dataset,
        colour_palette: ["c9d1d9"],
        mapping: %{category_col: "Source", value_cols: ["Leads"]}
      )

    Plot.new(600, 400, chart)
    |> Plot.titles("", "")
    |> Plot.axis_labels("", "Leads")
    |> Plot.to_svg()
    |> raw()
  end

  defp render_activities_per_user_chart(data) do
    chart_data = Enum.map(data, fn {user, count} -> [user, count] end)
    dataset = Dataset.new(chart_data, ["User", "Activities"])

    chart =
      BarChart.new(dataset,
        colour_palette: ["c9d1d9"],
        mapping: %{category_col: "User", value_cols: ["Activities"]}
      )

    Plot.new(600, 400, chart)
    |> Plot.titles("", "")
    |> Plot.axis_labels("", "Activities")
    |> Plot.to_svg()
    |> raw()
  end
end
