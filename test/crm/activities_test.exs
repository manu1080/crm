defmodule Crm.ActivitiesTest do
  use Crm.DataCase

  alias Crm.Activities
  alias Crm.{Repo, Leads, Stages}
  alias Crm.Sales.{Lead, Stage}

  describe "auto_stage_transition/2" do
    setup do
      stages = [
        %{name: "new", label: "New", order: 0, active: true},
        %{name: "contacted", label: "Contacted", order: 1, active: true},
        %{name: "qualified", label: "Qualified", order: 2, active: true},
        %{name: "meeting", label: "Meeting", order: 3, active: true},
        %{name: "negotiation", label: "Negotiation", order: 4, active: true},
        %{name: "deposit", label: "Deposit", order: 5, active: true},
        %{name: "notary", label: "Notary", order: 6, active: true},
        %{name: "management_contract", label: "Management Contract", order: 7, active: true},
        %{name: "won", label: "Won", order: 8, active: true},
        %{name: "lost", label: "Lost", order: 9, active: true}
      ]

      Enum.each(stages, fn stage_attrs ->
        %Stage{}
        |> Stage.changeset(stage_attrs)
        |> Repo.insert!()
      end)

      source =
        Crm.Repo.insert!(%Crm.Settings.Source{
          name: "test_source",
          description: "Test Source"
        })

      {:ok, source: source}
    end

    test "call_logged does not change stage", %{source: source} do
      contacted_stage = Stages.get_stage_by_name("contacted")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: contacted_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "call_logged",
          "description" => "Made a call"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == contacted_stage.id
    end

    test "meeting_completed advances from contacted to qualified", %{source: source} do
      contacted_stage = Stages.get_stage_by_name("contacted")
      qualified_stage = Stages.get_stage_by_name("qualified")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: contacted_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "meeting_completed",
          "description" => "Had a great meeting"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == qualified_stage.id
    end

    test "meeting_completed does not change stage if not in contacted", %{source: source} do
      new_stage = Stages.get_stage_by_name("new")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: new_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "meeting_completed"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == new_stage.id
    end

    test "offer_sent advances to meeting", %{source: source} do
      contacted_stage = Stages.get_stage_by_name("contacted")
      meeting_stage = Stages.get_stage_by_name("meeting")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: contacted_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "offer_sent",
          "description" => "Sent proposal"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == meeting_stage.id
    end

    test "offer_accepted advances to deposit", %{source: source} do
      meeting_stage = Stages.get_stage_by_name("meeting")
      deposit_stage = Stages.get_stage_by_name("deposit")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: meeting_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "offer_accepted",
          "description" => "They accepted!"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == deposit_stage.id
    end

    test "deposit_received advances to notary", %{source: source} do
      deposit_stage = Stages.get_stage_by_name("deposit")
      notary_stage = Stages.get_stage_by_name("notary")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: deposit_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "deposit_received",
          "description" => "Deposit confirmed!"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == notary_stage.id
    end

    test "notary_scheduled advances to management_contract", %{source: source} do
      notary_stage = Stages.get_stage_by_name("notary")
      management_contract_stage = Stages.get_stage_by_name("management_contract")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: notary_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "notary_scheduled",
          "description" => "Notary appointment set!"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == management_contract_stage.id
    end

    test "contract_signed advances to won", %{source: source} do
      management_contract_stage = Stages.get_stage_by_name("management_contract")
      won_stage = Stages.get_stage_by_name("won")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: management_contract_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "contract_signed",
          "description" => "Final contract signed!"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == won_stage.id
    end

    test "offer_rejected advances to lost", %{source: source} do
      meeting_stage = Stages.get_stage_by_name("meeting")
      lost_stage = Stages.get_stage_by_name("lost")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: meeting_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "offer_rejected"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == lost_stage.id
    end

    test "lead_lost advances to lost", %{source: source} do
      contacted_stage = Stages.get_stage_by_name("contacted")
      lost_stage = Stages.get_stage_by_name("lost")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: contacted_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "lead_lost",
          "description" => "No longer interested"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == lost_stage.id
    end

    test "lead_reactivated advances to contacted", %{source: source} do
      lost_stage = Stages.get_stage_by_name("lost")
      contacted_stage = Stages.get_stage_by_name("contacted")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: lost_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "lead_reactivated",
          "description" => "They called back!"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == contacted_stage.id
    end

    test "reminder_set does not change stage", %{source: source} do
      qualified_stage = Stages.get_stage_by_name("qualified")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: qualified_stage.id
        })
        |> Repo.insert!()

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "reminder_set",
          "description" => "Call back next week"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.stage_id == qualified_stage.id
    end

    test "all activities update last_activity_at", %{source: source} do
      new_stage = Stages.get_stage_by_name("new")

      lead =
        %Lead{}
        |> Lead.changeset(%{
          name: "Test Lead",
          email: "test@example.com",
          owner: "Test Owner",
          source_id: source.id,
          stage_id: new_stage.id
        })
        |> Repo.insert!()

      assert lead.last_activity_at == nil

      {:ok, _activity} =
        Activities.create_activity(%{
          "lead_id" => lead.id,
          "type" => "note_added",
          "description" => "Initial contact attempt"
        })

      updated_lead = Leads.get_lead!(lead.id)
      assert updated_lead.last_activity_at != nil
    end
  end
end
