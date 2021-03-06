defmodule CoursePlanner.Settings do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias CoursePlanner.{Repo, Settings.SystemVariable}
  alias Ecto.Multi
  # alias Calendar.DateTime, as: CalendarDateTime
  # alias Ecto.DateTime, as: EctoDateTime
  alias Timex.Timezone

  schema "settings_fake_table" do
    embeds_many :system_variables, SystemVariable
  end

  def get_changeset(system_variables) do
    system_variables
    |> Enum.map(&SystemVariable.changeset/1)
    |> wrap()
  end

  def wrap(system_variables) do
    %__MODULE__{}
    |> cast(%{}, [])
    |> put_embed(:system_variables, system_variables)
  end

  @all_query               from sv in SystemVariable, select: {sv.id, sv}, order_by: :key
  @visible_settings_query  from sv in SystemVariable, where: sv.visible, order_by: :key
  @editable_settings_query from sv in SystemVariable, where: sv.editable, order_by: :key

  def all do
    Repo.all(@all_query)
  end

  def get_value(name, default \\ nil) do
    system_variable = Repo.get_by(SystemVariable, key: name)

    {:ok, parsed_value} =
      cond do
        system_variable == nil -> {:ok, default}
        system_variable.value == nil -> {:ok, default}
        true   -> SystemVariable.parse_value(system_variable.value, system_variable.type)
      end

    parsed_value
  end

  def to_map(settings) do
    settings
    |> Enum.reduce(%{}, fn(systemvariable, out) ->
      Map.put(out, systemvariable.key, systemvariable.value)
    end)
  end

  def filter_system_variables(system_variables, setting_type) do
      case setting_type do
        "system"  -> {:ok, filter_non_program_systemvariables(system_variables)}
        "program" -> {:ok, filter_program_systemvariables(system_variables)}
        _         -> {:error, :not_found}
      end
  end

  def filter_non_program_systemvariables(settings) do
    Enum.reject(settings, &(String.starts_with?(&1.key, "PROGRAM")))
  end

  def filter_program_systemvariables(settings) do
    Enum.filter(settings, &(String.starts_with?(&1.key, "PROGRAM")))
  end

  def get_visible_systemvariables do
    Repo.all(@visible_settings_query)
  end

  def get_editable_systemvariables do
    Repo.all(@editable_settings_query)
  end

  def get_changesets_for_update(param_variables) do
    system_variables = all() |> Enum.into(Map.new)
    Enum.map(param_variables, &update_changeset(system_variables, &1))
  end

  defp update_changeset(system_variables, new_value) do
    {_pos, %{"id" => param_id, "value" => param_value}} = new_value
    {param_id, ""} = Integer.parse(param_id)
    found_system_variable = Map.get(system_variables, param_id)

    cond do
      is_nil(found_system_variable) -> :non_existing_resource
      not found_system_variable.editable -> :uneditable_resource
      found_system_variable.editable ->
        SystemVariable.changeset(found_system_variable, %{"value" => param_value}, :user_update)
    end
  end

  def update(changesets) do
    changesets
    |> Enum.reduce(Multi.new, &add_update_changeset/2)
    |> Repo.transaction()
  end

  defp add_update_changeset(:non_existing_resource, multi) do
    Multi.error(multi, :non_existing_resource, "Resource does not exist")
  end
  defp add_update_changeset(:uneditable_resource, multi) do
    Multi.error(multi, :uneditable_resource, "Resource is not editable")
  end
  defp add_update_changeset(changeset, multi) do
    name = changeset.data.id |> Integer.to_string |> String.to_atom
    Multi.update(multi, name, changeset)
  end

  def timezone_to_utc(datetime) do
    datetime
    |> add_timezone_info(get_system_timezone())
    |> Timezone.convert("Etc/UTC")
  end

  def utc_to_system_timezone(now \\ Timex.now()) do
    now
    |> add_timezone_info("Etc/UTC")
    |> Timezone.convert(get_system_timezone())
  end

  defp add_timezone_info(%NaiveDateTime{} = datetime, timezone) do
    case Calendar.DateTime.from_naive(datetime, timezone) do
      {:ok, datetime_with_tz} -> datetime_with_tz
      error -> error
    end
  end
  defp add_timezone_info(%Ecto.DateTime{} = datetime, timezone) do
    datetime
    |> Ecto.DateTime.to_erl()
    |> Calendar.DateTime.from_erl!(timezone)
  end
  defp add_timezone_info(%DateTime{} = datetime, timezone) do
    datetime
    |> DateTime.to_naive()
    |> add_timezone_info(timezone)
  end

  def get_system_timezone do
    case Repo.get_by(SystemVariable, key: "TIMEZONE") do
      %{value: nil} -> "Etc/UTC"
      %{value: value} -> value
      _ -> "Etc/UTC"
    end
  end
end
