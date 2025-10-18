defmodule CrmWeb.LeadLive.Form do
  use CrmWeb, :live_view

  alias Crm.Leads
  alias Crm.Stages
  alias Crm.Sales.Lead

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:sources, Crm.Settings.list_sources())
     |> assign(:stages, Stages.list_stages())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    # Get the default "new" stage
    new_stage = Enum.find(socket.assigns.stages, &(&1.name == "new"))

    socket
    |> assign(:page_title, "New Lead")
    |> assign(:lead, %Lead{stage_id: new_stage && new_stage.id})
    |> assign(:form, to_form(Leads.change_lead(%Lead{stage_id: new_stage && new_stage.id})))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    lead = Leads.get_lead!(id)

    socket
    |> assign(:page_title, "Edit Lead")
    |> assign(:lead, lead)
    |> assign(:form, to_form(Leads.change_lead(lead)))
  end

  @impl true
  def handle_event("validate", %{"lead" => lead_params}, socket) do
    changeset =
      socket.assigns.lead
      |> Leads.change_lead(lead_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"lead" => lead_params}, socket) do
    save_lead(socket, socket.assigns.live_action, lead_params)
  end

  defp save_lead(socket, :new, lead_params) do
    case Leads.create_lead(lead_params) do
      {:ok, _lead} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lead created successfully")
         |> push_navigate(to: ~p"/leads")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_lead(socket, :edit, lead_params) do
    case Leads.update_lead(socket.assigns.lead, lead_params) do
      {:ok, lead} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lead updated successfully")
         |> push_navigate(to: ~p"/leads/#{lead}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
