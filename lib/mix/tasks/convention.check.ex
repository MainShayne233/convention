defmodule Mix.Tasks.Convention.Check do
  @moduledoc """
  A mix task for running the convention checker.
  """

  def run([application_name]) when is_binary(application_name) do
    application = String.to_existing_atom(application_name)
    Application.ensure_started(application)
    Convention.SourceFile.all_for_application(application)
    |> IO.inspect
  end
end
