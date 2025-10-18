defmodule Crm.LeadsTest do
  use Crm.DataCase

  alias Crm.Leads
  alias Crm.Stages
  alias Crm.Sales.{Lead, Stage}
  alias Crm.Settings.Source

  setup do
    stages = [
      %{name: "new", label: "New", order: 1},
      %{name: "contacted", label: "Contacted", order: 2},
      %{name: "qualified", label: "Qualified", order: 3},
      %{name: "meeting", label: "Meeting", order: 4},
      %{name: "won", label: "Won", order: 5},
      %{name: "lost", label: "Lost", order: 6}
    ]

    Enum.each(stages, fn stage_attrs ->
      %Stage{}
      |> Stage.changeset(stage_attrs)
      |> Repo.insert!()
    end)

    source =
      %Source{}
      |> Source.changeset(%{name: "website", description: "Website leads"})
      |> Repo.insert!()

    %{source: source}
  end

  describe "create_lead/1" do
    test "creates a lead with valid attributes", %{source: source} do
      new_stage = Stages.get_stage_by_name("new")

      attrs = %{
        "name" => "John Doe",
        "email" => "john@example.com",
        "phone" => "+1234567890",
        "owner" => "Sales Rep",
        "source_id" => source.id,
        "stage_id" => new_stage.id
      }

      assert {:ok, %Lead{} = lead} = Leads.create_lead(attrs)
      assert lead.name == "John Doe"
      assert lead.email == "john@example.com"
      assert lead.phone == "+1234567890"
      assert lead.owner == "Sales Rep"
      assert lead.source_id == source.id
      assert lead.stage_id == new_stage.id
      assert lead.starred == false
      assert lead.last_activity_at == nil
    end
  end

  describe "update_lead/2" do
    setup %{source: source} do
      new_stage = Stages.get_stage_by_name("new")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Original Name",
          email: "original@example.com",
          owner: "Original Owner",
          source_id: source.id,
          stage_id: new_stage.id,
          starred: false
        })
        |> Repo.insert!()

      %{lead: lead}
    end

    test "updates lead with valid attributes", %{lead: lead} do
      attrs = %{
        "name" => "Updated Name",
        "email" => "updated@example.com",
        "phone" => "+9876543210"
      }

      assert {:ok, %Lead{} = updated_lead} = Leads.update_lead(lead, attrs)
      assert updated_lead.id == lead.id
      assert updated_lead.name == "Updated Name"
      assert updated_lead.email == "updated@example.com"
      assert updated_lead.phone == "+9876543210"
    end
  end

  describe "toggle_starred/1" do
    setup %{source: source} do
      new_stage = Stages.get_stage_by_name("new")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Owner",
          source_id: source.id,
          stage_id: new_stage.id,
          starred: false
        })
        |> Repo.insert!()

      %{lead: lead}
    end

    test "toggles starred from false to true", %{lead: lead} do
      assert lead.starred == false

      assert {:ok, %Lead{} = updated_lead} = Leads.toggle_starred(lead)
      assert updated_lead.starred == true
    end

    test "toggles starred from true to false", %{lead: lead} do
      {:ok, starred_lead} = Leads.toggle_starred(lead)
      assert starred_lead.starred == true

      assert {:ok, %Lead{} = unstarred_lead} = Leads.toggle_starred(starred_lead)
      assert unstarred_lead.starred == false
    end
  end

  describe "change_stage/2" do
    setup %{source: source} do
      new_stage = Stages.get_stage_by_name("new")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Owner",
          source_id: source.id,
          stage_id: new_stage.id
        })
        |> Repo.insert!()

      %{lead: lead, new_stage: new_stage}
    end

    test "changes lead to a new stage", %{lead: lead, new_stage: new_stage} do
      contacted_stage = Stages.get_stage_by_name("contacted")

      assert lead.stage_id == new_stage.id

      assert {:ok, %Lead{} = updated_lead} = Leads.change_stage(lead, "contacted")
      assert updated_lead.stage_id == contacted_stage.id
    end
  end
end
