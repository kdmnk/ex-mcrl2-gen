defmodule SimpleServerTest do
  use ExUnit.Case
  doctest SimpleServer

  test "greets the world" do
    assert SimpleServer.hello() == :world
  end
end
