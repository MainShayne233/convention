defmodule Convention.Check.FilenameModuleMatch do
  @moduledoc """
  Checks to see whether or not your application is following the filepath/module name convention
  """

  alias Convention.{Application, SourceFile}

  @type issue :: String.t()
  @type application_name :: atom()
  @type filepath :: String.t()

  @doc """
  Performs the filename module match check.
  """
  @spec check(Application.t()) :: :ok | {:error, [issue()]}
  def check(%Application{} = application) do
    Enum.reduce(application.source_files, [], fn %SourceFile{} = source_file, issues ->
      if adheres_to_convention?(application.name, source_file) do
        issues
      else
        [new_issue(source_file) | issues]
      end
    end)
  end

  @spec adheres_to_convention?(application_name(), SourceFile.t()) :: boolean()
  defp adheres_to_convention?(application_name, %SourceFile{filepath: filepath, modules: modules})
       when is_atom(application_name) and is_binary(filepath) and is_list(modules) do
    expected = conventional_module_name(application_name, filepath)
    IO.inspect({expected, modules})
    expected in modules
  end

  @spec conventional_module_name(application_name, filepath) :: module()
  defp conventional_module_name(application_name, filepath)
       when is_atom(application_name) and is_binary(filepath) do
    application_name_binary = Atom.to_string(application_name)

    filepath
    |> Path.split()
    |> get_project_chunks(application_name_binary)
    |> expected_module_name()
    |> IO.inspect(label: "Expected")
    |> safe_modulize
  end

  defp expected_module_name(["mix", "tasks" | rest]) do
    "Mix.Tasks." <> expected_module_name(rest)
  end

  defp expected_module_name(path_chunks) do
    path_chunks
    |> Enum.map(&normalize/1)
    |> Enum.join(".")
  end

  defp safe_modulize(string_module) do
    String.to_existing_atom("Elixir." <> string_module)
  rescue
    _ ->
      :non_existent_module
  end

  defp normalize(string) do
    string
    |> String.replace(~r/\.exs?/, "")
    |> String.split(".")
    |> Enum.map(fn substring ->
      substring
      |> Macro.camelize()
    end)
    |> Enum.join(".")
  end

  defp get_project_chunks([application_name_binary, "lib" | chunks], application_name_binary) do
    chunks
  end

  defp get_project_chunks([_junk | rest], application_name_binary) do
    get_project_chunks(rest, application_name_binary)
  end

  @spec new_issue(SourceFile.t()) :: String.t()
  defp new_issue(%SourceFile{}) do
    ":("
  end
end
