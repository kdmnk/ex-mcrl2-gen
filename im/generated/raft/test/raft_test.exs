defmodule RaftTest do
  use ExUnit.Case
  doctest Raft

  test "greets the world" do
    assert Raft.hello() == :world
  end
end
