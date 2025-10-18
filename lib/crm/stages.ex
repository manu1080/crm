defmodule Crm.Stages do
  @moduledoc """
  The Stages context.
  Manages sales pipeline stages.
  """

  import Ecto.Query, warn: false
  alias Crm.Repo
  alias Crm.Sales.Stage

  @doc """
  Returns the list of active stages ordered by their position.

  ## Examples

      iex> list_stages()
      [%Stage{}, ...]

  """
  def list_stages do
    Stage
    |> where([s], s.active == true)
    |> order_by([s], asc: s.order)
    |> Repo.all()
  end

  @doc """
  Gets a stage by name.

  ## Examples

      iex> get_stage_by_name("qualified")
      %Stage{}

      iex> get_stage_by_name("invalid")
      nil

  """
  def get_stage_by_name(name) when is_binary(name) do
    Stage
    |> where([s], s.name == ^name)
    |> Repo.one()
  end
end
