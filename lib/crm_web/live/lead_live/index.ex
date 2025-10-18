defmodule CrmWeb.LeadLive.Index do
  use CrmWeb, :live_view

  alias Crm.Leads
  alias Crm.Stages

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Leads.subscribe()

    {:ok,
     socket
     |> assign(:page_title, "Pipeline")
     |> assign(:filters, %{owner: nil, source: nil, starred: false})
     |> assign(:sources, Crm.Settings.list_sources())
     |> assign(:stages_list, Stages.list_stages())
     |> assign(:owners, Leads.list_owners())
     |> load_leads()}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("drop_lead", %{"id" => id, "stage" => stage}, socket) do
    lead = Leads.get_lead!(String.to_integer(id))

    case Leads.change_stage(lead, stage) do
      {:ok, _lead} ->
        {:noreply, load_leads(socket)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error moving lead")}
    end
  end

  @impl true
  def handle_event("change_stage", %{"id" => id, "stage" => stage}, socket) do
    lead = Leads.get_lead!(id)

    case Leads.change_stage(lead, stage) do
      {:ok, _lead} ->
        {:noreply, load_leads(socket)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error moving lead")}
    end
  end

  @impl true
  def handle_event("toggle_starred", %{"id" => id}, socket) do
    lead = Leads.get_lead!(id)

    case Leads.toggle_starred(lead) do
      {:ok, _lead} ->
        {:noreply, load_leads(socket)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error updating lead")}
    end
  end

  @impl true
  def handle_event(
        "filter",
        %{"owner" => owner, "source" => source, "starred" => starred},
        socket
      ) do
    filters = %{
      owner: if(owner == "", do: nil, else: owner),
      source: if(source == "", do: nil, else: source),
      starred: starred == "true"
    }

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_leads()}
  end

  # Handle when checkbox is unchecked (doesn't send starred param)
  @impl true
  def handle_event("filter", %{"owner" => owner, "source" => source}, socket) do
    filters = %{
      owner: if(owner == "", do: nil, else: owner),
      source: if(source == "", do: nil, else: source),
      starred: false
    }

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> load_leads()}
  end

  @impl true
  def handle_info({:lead_created, _lead}, socket) do
    {:noreply, load_leads(socket)}
  end

  @impl true
  def handle_info({:lead_updated, _lead}, socket) do
    {:noreply, load_leads(socket)}
  end

  @impl true
  def handle_info({:lead_deleted, _lead}, socket) do
    {:noreply, load_leads(socket)}
  end

  defp load_leads(socket) do
    filters = socket.assigns.filters
    filter_list = build_filter_list(filters)

    leads =
      if Enum.empty?(filter_list) do
        Leads.list_leads()
      else
        Leads.list_leads(filter_list)
      end

    # Group by stage_rel.name instead of the old stage string field
    leads_by_stage =
      leads
      |> Enum.group_by(fn lead ->
        if lead.stage_rel, do: lead.stage_rel.name, else: "new"
      end)
      |> Map.new(fn {stage, stage_leads} ->
        # Sort leads within each stage: starred first, then alphabetically by name
        sorted_leads =
          Enum.sort_by(stage_leads, fn lead ->
            {!lead.starred, String.downcase(lead.name)}
          end)

        {stage, sorted_leads}
      end)

    # Get stage names from the stages_list loaded in mount
    stage_names = Enum.map(socket.assigns.stages_list, & &1.name)

    socket
    |> assign(:leads_by_stage, leads_by_stage)
    |> assign(:stages, stage_names)
    |> assign(:stage_counts, count_stages(leads_by_stage, stage_names))
  end

  defp build_filter_list(filters) do
    []
    |> maybe_add_filter(:owner, filters.owner)
    |> maybe_add_filter(:source, filters.source)
    |> maybe_add_filter(:starred, filters.starred)
  end

  defp maybe_add_filter(list, _key, nil), do: list
  defp maybe_add_filter(list, :starred, false), do: list
  defp maybe_add_filter(list, key, value), do: [{key, value} | list]

  defp count_stages(leads_by_stage, stage_names) do
    stage_names
    |> Enum.map(fn stage ->
      {stage, length(Map.get(leads_by_stage, stage, []))}
    end)
    |> Map.new()
  end

  defp stage_label(stage_name, stages_list) do
    case Enum.find(stages_list, &(&1.name == stage_name)) do
      nil -> stage_name
      stage -> stage.label
    end
  end

  defp format_budget(nil), do: "-"

  defp format_budget(amount) do
    # Simple formatting with thousand separators
    amount
    |> to_string()
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.join(".")
    |> String.reverse()
    |> then(&"€#{&1}")
  end

  defp format_date(nil), do: "-"

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%d/%m/%y")
  end

  defp get_initials(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end

  defp export_query_params(filters) do
    %{
      owner: filters.owner || "all",
      source: filters.source || "all",
      starred: to_string(filters.starred)
    }
  end
end
