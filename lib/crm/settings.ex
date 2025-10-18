defmodule Crm.Settings do
  @moduledoc """
  The Settings context.
  Manages application configuration and reference data such as lead sources.

  Lead sources track where leads originate from (website, referral, social media, etc.)
  and are used for analytics and filtering throughout the application.
  """

  alias Crm.Repo
  alias Crm.Settings.Source

  @doc """
  Returns the list of all sources.

  ## Examples

      iex> list_sources()
      [%Source{}, ...]

  """
  def list_sources do
    Repo.all(Source)
  end
end
