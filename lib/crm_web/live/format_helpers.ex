defmodule CrmWeb.FormatHelpers do
  @moduledoc """
  Shared formatting functions for LiveViews.
  Provides consistent formatting for currency, dates, and user initials.
  """

  @doc """
  Formats a budget amount with thousand separators and Euro symbol.

  ## Examples

      iex> FormatHelpers.format_budget(1000)
      "€1.000"

      iex> FormatHelpers.format_budget(nil)
      "-"
  """
  def format_budget(nil), do: "-"

  def format_budget(amount) do
    amount
    |> to_string()
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.join(".")
    |> String.reverse()
    |> then(&"€#{&1}")
  end

  @doc """
  Formats a datetime in short format (dd/mm/yy).

  ## Examples

      iex> FormatHelpers.format_date_short(~U[2024-01-15 10:30:00Z])
      "15/01/24"

      iex> FormatHelpers.format_date_short(nil)
      "-"
  """
  def format_date_short(nil), do: "-"

  def format_date_short(datetime) do
    Calendar.strftime(datetime, "%d/%m/%y")
  end

  @doc """
  Formats a datetime in long format (dd/mm/yyyy).

  ## Examples

      iex> FormatHelpers.format_date_long(~U[2024-01-15 10:30:00Z])
      "15/01/2024"

      iex> FormatHelpers.format_date_long(nil)
      "-"
  """
  def format_date_long(nil), do: "-"

  def format_date_long(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y")
  end

  @doc """
  Formats a datetime as relative time from now.

  ## Examples

      iex> FormatHelpers.format_relative_time(DateTime.add(DateTime.utc_now(), -30, :second))
      "Just now"

      iex> FormatHelpers.format_relative_time(DateTime.add(DateTime.utc_now(), -120, :second))
      "2m ago"
  """
  def format_relative_time(datetime) do
    now = DateTime.utc_now()
    diff_seconds = DateTime.diff(now, datetime, :second)

    cond do
      diff_seconds < 60 -> "Just now"
      diff_seconds < 3600 -> "#{div(diff_seconds, 60)}m ago"
      diff_seconds < 86400 -> "#{div(diff_seconds, 3600)}h ago"
      diff_seconds < 604_800 -> "#{div(diff_seconds, 86400)}d ago"
      true -> format_date_long(datetime)
    end
  end

  @doc """
  Gets initials from a name (first two words).

  ## Examples

      iex> FormatHelpers.get_initials("John Doe")
      "JD"

      iex> FormatHelpers.get_initials("Jane Marie Smith")
      "JM"
  """
  def get_initials(name) do
    name
    |> String.split()
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end
end
