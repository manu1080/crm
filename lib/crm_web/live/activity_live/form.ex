defmodule CrmWeb.ActivityLive.Form do
  use CrmWeb, :live_view

  alias Crm.Leads
  alias Crm.Activities
  alias Crm.Sales.Activity

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:activity_types, Activity.activity_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, params) do
    # Get lead_id from params if provided
    lead_id = Map.get(params, "lead_id")

    # Load all leads for the dropdown
    leads = Leads.list_leads()

    socket
    |> assign(:page_title, "New Activity")
    |> assign(:activity, %Activity{lead_id: lead_id && String.to_integer(lead_id)})
    |> assign(:leads, leads)
    |> assign(:form, to_form(Activities.change_activity(%Activity{lead_id: lead_id && String.to_integer(lead_id)})))
  end

  @impl true
  def handle_event("validate", %{"activity" => activity_params}, socket) do
    changeset =
      socket.assigns.activity
      |> Activities.change_activity(activity_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"activity" => activity_params}, socket) do
    case Activities.create_activity(activity_params) do
      {:ok, activity} ->
        lead = Leads.get_lead!(activity.lead_id)

        {:noreply,
         socket
         |> put_flash(:info, "Activity created successfully")
         |> push_navigate(to: ~p"/leads/#{lead}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
