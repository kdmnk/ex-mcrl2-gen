defmodule AdditionTest do
  use ExUnit.Case
  doctest Addition

  test "greets the world" do
    assert Addition.hello() == :world
  end
end
