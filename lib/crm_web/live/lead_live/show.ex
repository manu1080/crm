defmodule CrmWeb.LeadLive.Show do
  use CrmWeb, :live_view

  alias Crm.Leads
  alias Crm.Activities
  alias Crm.Sales.Activity
  import CrmWeb.ActivityHelpers
  import CrmWeb.FormatHelpers
  import CrmWeb.AuthorizationHelpers

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Leads.subscribe()

    current_user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:show_activity_form, false)
     |> assign(:activity_types, Activity.activity_types())
     |> assign(:can_update, can?(current_user, "leads", "update"))
     |> assign(:can_delete, can?(current_user, "leads", "delete"))
     |> assign(:can_create_activity, can?(current_user, "activities", "create"))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    lead = Leads.get_lead!(id)

    {:noreply,
     socket
     |> assign(:page_title, "Lead Details")
     |> assign(:lead, lead)
     |> assign(
       :activity_form,
       to_form(Activities.change_activity(%Activity{lead_id: String.to_integer(id)}))
     )}
  end

  @impl true
  def handle_event("toggle_activity_form", _, socket) do
    {:noreply, assign(socket, :show_activity_form, !socket.assigns.show_activity_form)}
  end

  @impl true
  def handle_event("quick_action", %{"type" => type}, socket) do
    # Create activity with the quick action type
    activity_params = %{
      "lead_id" => socket.assigns.lead.id,
      "type" => type,
      "description" => "Quick action: #{Activity.type_label(type)}"
    }

    case Activities.create_activity(activity_params) do
      {:ok, _activity} ->
        lead = Leads.get_lead!(socket.assigns.lead.id)

        {:noreply,
         socket
         |> assign(:lead, lead)
         |> put_flash(:info, "#{Activity.type_label(type)} recorded successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to record activity")}
    end
  end

  @impl true
  def handle_event("validate_activity", %{"activity" => activity_params}, socket) do
    changeset =
      %Activity{lead_id: socket.assigns.lead.id}
      |> Activities.change_activity(activity_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :activity_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save_activity", %{"activity" => activity_params}, socket) do
    activity_params = Map.put(activity_params, "lead_id", socket.assigns.lead.id)

    case Activities.create_activity(activity_params) do
      {:ok, _activity} ->
        lead = Leads.get_lead!(socket.assigns.lead.id)

        {:noreply,
         socket
         |> assign(:lead, lead)
         |> assign(:show_activity_form, false)
         |> assign(
           :activity_form,
           to_form(Activities.change_activity(%Activity{lead_id: lead.id}))
         )
         |> put_flash(:info, "Activity created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :activity_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_info({:lead_updated, updated_lead}, socket) do
    # Only reload if it's the lead we're viewing
    if updated_lead.id == socket.assigns.lead.id do
      lead = Leads.get_lead!(updated_lead.id)
      {:noreply, assign(socket, :lead, lead)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:lead_deleted, deleted_lead}, socket) do
    # Redirect to index if the lead we're viewing was deleted
    if deleted_lead.id == socket.assigns.lead.id do
      {:noreply,
       socket
       |> put_flash(:info, "Lead was deleted")
       |> push_navigate(to: ~p"/leads")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(_msg, socket), do: {:noreply, socket}
end
