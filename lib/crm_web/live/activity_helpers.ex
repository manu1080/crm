defmodule CrmWeb.ActivityHelpers do
  @moduledoc """
  Helper functions for displaying activities in LiveViews.
  """

  @doc """
  Returns the icon name for an activity type.
  """
  def activity_icon(type) do
    case type do
      "call_logged" -> "hero-phone"
      "meeting_completed" -> "hero-calendar"
      "offer_sent" -> "hero-document-text"
      "offer_accepted" -> "hero-check-circle"
      "deposit_received" -> "hero-currency-dollar"
      "notary_scheduled" -> "hero-building-library"
      "contract_signed" -> "hero-document-check"
      "offer_rejected" -> "hero-x-circle"
      "reminder_set" -> "hero-bell"
      "note_added" -> "hero-pencil-square"
      "lead_lost" -> "hero-x-mark"
      "lead_reactivated" -> "hero-arrow-path"
      "email_sent" -> "hero-envelope"
      "whatsapp_sent" -> "hero-chat-bubble-left-right"
      _ -> "hero-information-circle"
    end
  end

  @doc """
  Returns the background color class for an activity type.
  """
  def activity_icon_bg(type) do
    case type do
      "call_logged" -> "bg-blue-500"
      "meeting_completed" -> "bg-purple-500"
      "offer_sent" -> "bg-orange-500"
      "offer_accepted" -> "bg-green-500"
      "deposit_received" -> "bg-emerald-500"
      "notary_scheduled" -> "bg-cyan-500"
      "contract_signed" -> "bg-teal-600"
      "offer_rejected" -> "bg-red-500"
      "reminder_set" -> "bg-yellow-500"
      "note_added" -> "bg-gray-500"
      "lead_lost" -> "bg-red-600"
      "lead_reactivated" -> "bg-teal-500"
      "email_sent" -> "bg-indigo-500"
      "whatsapp_sent" -> "bg-green-600"
      _ -> "bg-gray-400"
    end
  end
end
