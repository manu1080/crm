defmodule Crm.Reports do
  @moduledoc """
  The Reports context for generating CSV exports and reports.
  """

  import Ecto.Query
  alias Crm.Repo
  alias Crm.Sales.{Lead, Stage, Activity}
  alias Crm.Settings.Source

  NimbleCSV.define(LeadCSV, separator: ",", escape: "\"")

  @doc """
  Exports leads to CSV format with stage and activity information.

  ## Options

    * `:date_range` - Filter by creation date (days ago)
    * `:owner` - Filter by owner name
    * `:source_id` - Filter by source ID
    * `:stage_id` - Filter by stage ID

  ## Examples

      iex> export_leads_csv()
      "id,name,email,phone,owner,budget..."

      iex> export_leads_csv(owner: "Ana García")
      "id,name,email,phone,owner,budget..."

  """
  def export_leads_csv(opts \\ []) do
    leads = get_leads_with_details(opts)

    headers = [
      "id",
      "name",
      "email",
      "phone",
      "owner",
      "budget",
      "starred",
      "created_at",
      "last_activity_at",
      "stage_label",
      "source_name",
      "total_activities",
      "last_activity_type",
      "last_activity_description",
      "last_activity_date"
    ]

    rows = Enum.map(leads, &lead_to_csv_row/1)

    # Add UTF-8 BOM for Excel compatibility
    bom = <<0xEF, 0xBB, 0xBF>>
    csv_content = LeadCSV.dump_to_iodata([headers | rows])

    bom <> IO.iodata_to_binary(csv_content)
  end

  @doc """
  Gets the filename for the CSV export.
  """
  def export_filename do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y%m%d_%H%M%S")
    "crm_leads_export_#{timestamp}.csv"
  end

  # Private functions

  defp get_leads_with_details(opts) do
    date_range = Keyword.get(opts, :date_range)
    owner = Keyword.get(opts, :owner)
    source_id = Keyword.get(opts, :source_id)
    stage_id = Keyword.get(opts, :stage_id)

    query =
      from(l in Lead,
        join: st in Stage,
        on: l.stage_id == st.id,
        join: src in Source,
        on: l.source_id == src.id,
        left_join: a in Activity,
        on: a.lead_id == l.id,
        group_by: [l.id, st.id, src.id],
        select: %{
          id: l.id,
          name: l.name,
          email: l.email,
          phone: l.phone,
          owner: l.owner,
          budget: l.budget,
          starred: l.starred,
          created_at: l.inserted_at,
          last_activity_at: l.last_activity_at,
          stage_label: st.label,
          source_name: src.name,
          total_activities: count(a.id)
        },
        order_by: [desc: l.inserted_at]
      )

    # Apply filters
    query =
      if date_range do
        days = String.to_integer(date_range)
        cutoff = DateTime.utc_now() |> DateTime.add(-days * 24 * 3600, :second)
        where(query, [l], l.inserted_at >= ^cutoff)
      else
        query
      end

    query = if owner && owner != "all", do: where(query, [l], l.owner == ^owner), else: query

    query =
      if source_id && source_id != "all",
        do: where(query, [l], l.source_id == ^String.to_integer(source_id)),
        else: query

    query =
      if stage_id && stage_id != "all",
        do: where(query, [l], l.stage_id == ^String.to_integer(stage_id)),
        else: query

    leads = Repo.all(query)

    # Enrich with activity details
    Enum.map(leads, fn lead ->
      activity_details = get_activity_details(lead.id)
      Map.merge(lead, activity_details)
    end)
  end

  defp get_activity_details(lead_id) do
    # Get last activity
    last_activity =
      from(a in Activity,
        where: a.lead_id == ^lead_id,
        order_by: [desc: a.inserted_at],
        limit: 1,
        select: %{
          type: a.type,
          description: a.description,
          date: a.inserted_at
        }
      )
      |> Repo.one()

    %{
      last_activity_type: if(last_activity, do: last_activity.type, else: nil),
      last_activity_description: if(last_activity, do: last_activity.description, else: nil),
      last_activity_date: if(last_activity, do: last_activity.date, else: nil)
    }
  end

  defp lead_to_csv_row(lead) do
    [
      to_string(lead.id),
      lead.name || "",
      lead.email || "",
      lead.phone || "",
      lead.owner || "",
      to_string(lead.budget || 0),
      to_string(lead.starred),
      format_datetime(lead.created_at),
      format_datetime(lead.last_activity_at),
      lead.stage_label || "",
      lead.source_name || "",
      to_string(lead.total_activities || 0),
      lead.last_activity_type || "",
      lead.last_activity_description || "",
      format_datetime(lead.last_activity_date)
    ]
  end

  defp format_datetime(nil), do: ""

  defp format_datetime(datetime) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end
end
