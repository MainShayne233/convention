defmodule ConventionTest do
  use ExUnit.Case
  doctest Convention

  test "greets the world" do
    assert Convention.hello() == :world
  end
end
