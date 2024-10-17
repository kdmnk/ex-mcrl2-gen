defmodule Im.Gen.Helpers do

  def write(%Im.Gen.GenState{} = state, str, ending \\ "") do
    IO.binwrite(state.file, str <> ending)
  end
  def writeLn(%Im.Gen.GenState{} = state, str, indent \\ 0, ending \\ "\n") do
    write(state, String.duplicate(" ", state.indentation + indent) <> str, ending)
  end

  def getState(state) do
    extState = Map.put(state, "pid", "Pid") # add own pid
    extState
    |> Map.keys()
    |> Enum.map(fn s -> "#{s}: #{typeToMcrl2(extState[s])}" end)
    |> Enum.join(", ")
  end

  def getNextId() do
    if Process.whereis(:randomAgent) == nil do
      {:ok, randomAgent} = Agent.start_link(fn -> 0 end)
      Process.register(randomAgent, :randomAgent)
    end

    Agent.get_and_update(:randomAgent, fn i -> {i, i + 1} end)
  end

  defp typeToMcrl2(type) do
    case type do
      {:pid, _} -> "Pid"
      p -> p
    end
  end
end
