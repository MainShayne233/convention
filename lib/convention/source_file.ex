defmodule Convention.SourceFile do
  @moduledoc """
  Defines a struct representing an Elixir source file.
  """

  alias Convention.SourceFile

  use TypedStruct

  @typedoc "An Elixir source file."
  typedstruct do
    field(:filepath, String.t(), enforce: true)
    field(:modules, [module()], enforce: true)
  end

  @doc """
  Provides all of the source files for the given application.
  """
  @spec all_for_application(application :: atom()) :: [t()] | no_return()
  def all_for_application(application) when is_atom(application) do
    {:ok, modules} = :application.get_key(application, :modules)
    do_all_for_application(modules)
  end

  @spec do_all_for_application([module()], source_file_table :: map()) :: [t()] | no_return()
  defp do_all_for_application(modules, source_file_table \\ %{})

  defp do_all_for_application([], %{} = source_file_table) do
    Enum.map(source_file_table, fn {filepath, modules} ->
      %SourceFile{filepath: to_string(filepath), modules: modules}
    end)
  end

  defp do_all_for_application([module | rest], %{} = source_file_table) do
    source_path =
      module.module_info[:compile][:source]

    case source_file_table do
      %{^source_path => [_ | _] = modules} ->
        do_all_for_application(rest, %{source_file_table | source_path => [module | modules]})

      _ ->
        do_all_for_application(rest, Map.put(source_file_table, source_path, [module]))
    end
  end
end
