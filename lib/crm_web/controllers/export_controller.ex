defmodule CrmWeb.ExportController do
  use CrmWeb, :controller
  alias Crm.Reports

  @doc """
  Exports leads to CSV format.
  Accepts query parameters for filtering.
  """
  def leads_csv(conn, params) do
    opts = [
      date_range: params["date_range"],
      owner: params["owner"],
      source_id: params["source_id"],
      stage_id: params["stage_id"]
    ]

    csv_content = Reports.export_leads_csv(opts)
    filename = Reports.export_filename()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_resp(200, csv_content)
  end
end
