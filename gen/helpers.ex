defmodule Helpers do
  def write(file, str, ending \\ "") do
    IO.binwrite(file, str <> ending)
  end
  def writeLn(file, str, indent, ending \\ "\n") do
    write(file, String.duplicate(" ", indent) <> str, ending)
  end


  def getNextId() do
    if Process.whereis(:randomAgent) == nil do
      {:ok, randomAgent} = Agent.start_link(fn -> 0 end)
      Process.register(randomAgent, :randomAgent)
    end

    Agent.get_and_update(:randomAgent, fn i -> {i, i + 1} end)
  end

end
