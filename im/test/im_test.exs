defmodule ImTest do
  use ExUnit.Case
  doctest Im

  test "greets the world" do
    assert hello() == :world
  end
end
