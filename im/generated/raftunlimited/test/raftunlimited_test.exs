defmodule RaftunlimitedTest do
  use ExUnit.Case
  doctest Raftunlimited

  test "greets the world" do
    assert Raftunlimited.hello() == :world
  end
end
