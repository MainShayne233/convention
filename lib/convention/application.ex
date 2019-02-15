defmodule Convention.Application do
  @moduledoc """
  Defines a struct representing an Elixir application.
  """

  use TypedStruct

  alias Convention.{Application, SourceFile}

  typedstruct do
    field(:name, atom(), enforce: true)
    field(:source_files, [SourceFile.t()], enforce: true)
  end

  @doc """
  Creates a new Application for struct for the given name.
  """
  @spec new(application_name :: atom()) :: t() | no_return()
  def new(application_name) when is_atom(application_name) do
    %Application{
      name: application_name,
      source_files: SourceFile.all_for_application(application_name)
    }
  end
end
