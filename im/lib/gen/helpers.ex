defmodule Gen.Helpers do

  def write(%Gen.GenState{} = state, str, ending \\ "") do
    IO.binwrite(state.file, str <> ending)
  end
  def writeLn(%Gen.GenState{} = state, str, indent \\ 0, ending \\ "\n") do
    write(state, String.duplicate(" ", (state.indentation + indent)*2) <> str, ending)
  end

  def getCommands(cmdType, cmds, acc \\ []) do
    Enum.reduce(cmds, acc, fn cmd, acc ->
      case cmd do
        %^cmdType{} -> [cmd | acc]
        _ ->
          case Map.get(cmd, :body) do
            nil -> acc
            body -> getCommands(cmdType, body, acc)
          end
      end
    end)
  end

  def getState(state) do
    state
    |> Keyword.keys()
    |> Enum.map(fn s -> "#{s}: #{typeToMcrl2(state[s])}" end)
    |> Enum.join(", ")
  end

  def getNextId() do
    if Process.whereis(:randomAgent) == nil do
      {:ok, randomAgent} = Agent.start_link(fn -> 0 end)
      Process.register(randomAgent, :randomAgent)
    end

    Agent.get_and_update(:randomAgent, fn i -> {i, i + 1} end)
  end

  def addNonDeterministicChoice(choice) do
    if Process.whereis(:choiceAgent) == nil do
      {:ok, choiceAgent} = Agent.start_link(fn -> [] end)
      Process.register(choiceAgent, :choiceAgent)
    end

    Agent.update(:choiceAgent, fn choices -> [choice | choices] end)
  end

  def getNonDeterministicChoices() do
    if Process.whereis(:choiceAgent) == nil do
      {:ok, choiceAgent} = Agent.start_link(fn -> [] end)
      Process.register(choiceAgent, :choiceAgent)
    end

    Agent.get(:choiceAgent, fn i -> i end)
  end

  def pidName(name) do
    cleaned = String.replace_prefix(to_string(name), "Elixir.", "")
    String.downcase("#{cleaned}") <> "_pid"
  end

  def joinStr(callback, list, separator \\ "\n")
  def joinStr(_, [], _), do: ""
  def joinStr(callback, [l | []], _) do
    callback.(l)
  end
  def joinStr(callback, [l | ls], separator) do
    "#{callback.(l)}#{separator}#{joinStr(callback, ls, separator)}"
  end

  def join(callback, list, separator)
  def join(_, [], _), do: ""
  def join(callback, [l | []], _) do
    callback.(l)
  end
  def join(callback, [l | ls], separator) do
    callback.(l)
    separator.()
    join(callback, ls, separator)
  end

  def typeToMcrl2(type) do
    case type do
      {:pid, _} -> "Pid"
      {:list, type} -> "List(#{typeToMcrl2(type)})"
      {:set, type} -> "FSet(#{typeToMcrl2(type)})"
      p -> p
    end
  end
end
