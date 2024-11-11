defmodule Im.Process do
  alias Im.Gen.GenMcrl2

  defstruct [:identifier, :state, :run]

  def writeMcrl2(%Im.Process{} = p, state) do
    Im.Gen.Helpers.writeLn(state, "#{p.identifier}(#{Im.Gen.Helpers.getState(p.state)}) = ")

    GenMcrl2.writeCmds(Im.Gen.GenState.indent(Im.Gen.GenState.addBoundVars(state, ["pid" | stateList(p)])), p.run)

    Im.Gen.Helpers.writeLn(state, ". #{p.identifier}();", +1)
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.Process{} = p) do
    GenEx.writeBlock(state, "defmodule #{p.identifier} do", fn s ->
      s = %{s |
        bounded_vars: s.bounded_vars ++ Im.Process.stateList(p),
        module_name: p.identifier,
        module_state: Im.Process.stateList(p)}


      Im.Gen.Helpers.writeLn(s, "use GenServer\n")
      GenEx.writeBlock(s, "defmodule InitState do", fn s ->
        Im.Gen.Helpers.writeLn(s, "defstruct [:pid]")
      end)
      GenEx.writeBlock(s, "defmodule ChoiceState do", fn s ->
        Im.Gen.Helpers.writeLn(s, "defstruct [:choice, :vars]")
      end)
      GenEx.writeBlock(s, "defmodule DoneState do", fn s ->
        Im.Gen.Helpers.writeLn(s, "defstruct []")
      end)
      GenEx.writeBlock(s, "def start(#{stateStr(p)}) do", fn s ->
        GenEx.writeBlock(s, "if Process.whereis(__MODULE__) do", fn s ->
          Im.Gen.Helpers.writeLn(s, "GenServer.stop(__MODULE__)")
        end)
        Im.Gen.Helpers.writeLn(s, "{:ok, pid} = GenServer.start_link(__MODULE__, [#{stateStr(p)}], name: __MODULE__)")
        Im.Gen.Helpers.writeLn(s, "%InitState{pid: pid}")
      end)
      GenEx.writeBlock(s, "def wait(%InitState{}) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "GenServer.call(__MODULE__, :wait)")
      end)
      GenEx.writeBlock(s, "def chooseAnswer(%ChoiceState{}, choice) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "GenServer.call(__MODULE__, {:chooseAnswer, choice})")
      end)
      GenEx.writeBlock(s, "def init(_arg) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "{:ok, {%{}, nil}}")
      end)
      GenEx.writeBlock(s, "def handle_call(:wait, from, {state, true}) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "{:reply, state, {state, nil}}")
      end)
      GenEx.writeBlock(s, "def handle_call(:wait, from, {state, nil}) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "{:noreply, {state, from}}")
      end)

      choices = getChoices(p.run, [])
      Enum.map(choices, fn cmd ->
        [case1, case2] = cmd.body
        GenEx.writeBlock(s, "def handle_call({:#{cmd.label}, true}, _from, {state, waiting}) do", fn s ->
          Im.Commands.writeEx(s, case1)
          Im.Gen.Helpers.writeLn(s, "{:reply, %DoneState{}, {%DoneState{}, waiting}}")
        end)
        GenEx.writeBlock(s, "def handle_call({:#{cmd.label}, false}, _from, {state, waiting}) do", fn s ->
          Im.Commands.writeEx(s, case2)
          Im.Gen.Helpers.writeLn(s, "{:reply, %DoneState{}, {%DoneState{}, waiting}}")
        end)
      end)

      Enum.map(p.run, fn cmd ->
        Im.Commands.writeEx(s, cmd)
      end)
    end)
  end


  def getChoices(cmds, acc) do
    Enum.reduce(cmds, acc, fn cmd, acc ->
      case cmd do
        %Im.Commands.Choice{} -> [cmd | acc]
        _ ->
          case Map.get(cmd, :body) do
            nil -> acc
            body -> getChoices(body, acc)
          end
      end
    end)
  end

  def stateList(%Im.Process{} = p), do: Keyword.keys(p.state)

  def stateStr(%Im.Process{} = p) do
    Keyword.keys(p.state) |> Enum.join(", ")
  end

  def statePidNamesStr(%Im.Process{} = p) do
    Keyword.values(p.state)
    |> Enum.map(fn {:pid, name} -> Im.Gen.Helpers.pidName(name) end)
    |> Enum.join(", ")
  end

end
