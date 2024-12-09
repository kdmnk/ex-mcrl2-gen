defmodule Processes.Process do
  alias Gen.GenMcrl2
  alias Gen.GenEx

  defstruct [:identifier, :state, :run, :quantity]

  def writeMcrl2(%__MODULE__{} = p, state) do
    Gen.Helpers.writeLn(state, "#{p.identifier}(#{Gen.Helpers.getState(state.module_state)}) = ")

    GenMcrl2.writeCmds(Gen.GenState.indent(Gen.GenState.addBoundVars(state, ["pid" | stateList(p)])), p.run)
    Gen.Helpers.writeLn(state, ";")
  end

  def writeEx(%Gen.GenState{} = state, %Gen.GenState{} = stateApi, %__MODULE__{} = p, subprocesses) do

    choices = getCommands(Commands.Choice, p.run, [])

    GenEx.writeBlock(stateApi, "defmodule #{p.identifier}Api do", fn s ->
      s = %{s |
        module_name: p.identifier <> "Api",
      }

      Gen.Helpers.writeLn(s, "use GenServer")
      Gen.Helpers.writeLn(s, "require Logger\n")

      GenEx.writeBlock(s, "defmodule IdleState do", fn s ->
        Gen.Helpers.writeLn(s, "defstruct []")
      end)

      Enum.map(choices, fn cmd ->
        GenEx.writeBlock(s, "defmodule Choice#{Commands.Choice.getStateLabel(cmd)}State do", fn s ->
          Gen.Helpers.writeLn(s, "defstruct [:choice, :vars]")
        end)
      end)

      GenEx.writeBlock(s, "def start_link(_) do", fn s ->
        Gen.Helpers.writeLn(s, "GenServer.start_link(__MODULE__, %{}, name: __MODULE__)")
      end)

      GenEx.writeBlock(s, "def start() do", fn s ->
        Gen.Helpers.writeLn(s, "GenServer.cast({#{p.identifier}, Node.self()}, :start)")
        Gen.Helpers.writeLn(s, "%IdleState{}")
      end)

      if choices != [] do
        GenEx.writeBlock(s, "def wait(%IdleState{}) do", fn s ->
          Gen.Helpers.writeLn(s, "GenServer.call({__MODULE__, Node.self()}, :wait, :infinity)")
        end)

        Enum.map(choices, fn cmd ->
          GenEx.writeBlock(s, "def choose#{Commands.Choice.getStateLabel(cmd)}(%Choice#{Commands.Choice.getStateLabel(cmd)}State{}, choice) do", fn s ->
            Gen.Helpers.writeLn(s, "GenServer.cast({#{p.identifier}, Node.self()}, {:#{cmd.label}, choice})")
            Gen.Helpers.writeLn(s, "%IdleState{}")
          end)
        end)
      end

      GenEx.writeBlock(s, "def init(_) do", fn s ->
        Gen.Helpers.writeLn(s, "{:ok, {nil, nil}}")
      end)

      if choices != [] do
        GenEx.writeBlock(s, "def handle_call(:wait, _from, {choiceState, nil}) when not is_nil(choiceState) do", fn s ->
          GenEx.writeLog(s, "Started waiting. Replying with already updated state.")
          Gen.Helpers.writeLn(s, "{:reply, choiceState, {nil, nil}}")
        end)

        GenEx.writeBlock(s, "def handle_call(:wait, from, {nil, nil}) do", fn s ->
          GenEx.writeLog(s, "Started waiting.")
          Gen.Helpers.writeLn(s, "{:noreply, {nil, from}}")
        end)

        GenEx.writeBlock(s, "def handle_cast({:new_choice, choiceState},{nil, nil}) do", fn s ->
          GenEx.writeLog(s, "got new state but client is not waiting yet")
          Gen.Helpers.writeLn(s, "{:noreply, {choiceState, nil}}")
        end)
        GenEx.writeBlock(s, "def handle_cast({:new_choice, choiceState},{nil, from}) do", fn s ->
          GenEx.writeLog(s, "replying to wait")
          Gen.Helpers.writeLn(s, "GenServer.reply(from, choiceState)")
          Gen.Helpers.writeLn(s, "{:noreply, {nil, nil}}")
        end)
      end
    end)


    GenEx.writeBlock(state, "defmodule #{p.identifier} do", fn s ->
      s = %{s |
        bounded_vars: s.bounded_vars ++ stateList(p),
        module_name: p.identifier,
        module_state: stateList(p)}

      Gen.Helpers.writeLn(s, "use GenServer")
      Gen.Helpers.writeLn(s, "require Logger\n")

      GenEx.writeBlock(s, "def start_link(vars) do", fn s ->
        Gen.Helpers.writeLn(s, "GenServer.start_link(__MODULE__, vars, name: __MODULE__)")
      end)

      GenEx.writeBlock(s, "def init(vars) do", fn s ->
        Gen.Helpers.writeLn(s, "vars = %{#{stateInit(p)}}")
        GenEx.writeLog(s, "initialised with \#{inspect(vars)}")
        Gen.Helpers.writeLn(s, "{:ok, vars}")
      end)

      GenEx.writeBlock(s, "def handle_cast(:start, state) do", fn s ->
        GenEx.writeCmds(s, p.run)
        Gen.Helpers.writeLn(s, "{:noreply, state}")
      end)

      Enum.map(choices, fn cmd ->
        [case1, case2] = cmd.body
        GenEx.writeBlock(s, "def handle_cast({:#{cmd.label}, true}, state) do", fn s ->
          GenEx.writeCmds(s, [case1])
          Gen.Helpers.writeLn(s, "{:noreply, state}")
        end)
        GenEx.writeBlock(s, "def handle_cast({:#{cmd.label}, false}, state) do", fn s ->
          GenEx.writeCmds(s, [case2])
          Gen.Helpers.writeLn(s, "{:noreply, state}")
        end)
      end)

      all_cmds = Enum.reduce(subprocesses, p.run, fn (s, acc) -> s.run ++ acc end)
      recs = getCommands(Commands.Receive, all_cmds, [])
      Enum.map(recs, fn cmd ->
          Commands.Receive.writeEx(s, cmd)
      end)

      Enum.map(subprocesses, fn sp ->
        Processes.SubProcess.writeEx(s, sp)
      end)

      GenEx.writeBlock(s, "defp updateState(state, new_map) do", fn s ->
        Gen.Helpers.writeLn(s, "Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)")
      end)

      GenEx.writeBlock(s, "defp var(state, key) do", fn s ->
        Gen.Helpers.writeLn(s, "Map.get(state, key, key)")
      end)
    end)
  end


  def getCommands(cmdType, cmds, acc) do
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

  def stateList(%__MODULE__{} = p), do: Keyword.keys(p.state)

  def stateStr(%__MODULE__{} = p) do
    Keyword.keys(p.state) |> Enum.join(", ")
  end

  def stateMap(%__MODULE__{} = p) do
    Keyword.keys(p.state) |> Enum.map(fn s -> ":#{s} => #{s}" end) |> Enum.join(", ")
  end

  def stateInit(%__MODULE__{} = p) do
    Keyword.keys(p.state) |> Enum.map(fn s -> ":#{s} => var(vars, :#{s})" end) |> Enum.join(", ")
  end

  def statePidNamesStr(%__MODULE__{} = p) do
    Keyword.values(p.state)
    |> Enum.map(fn {:pid, name} -> Gen.Helpers.pidName(name) end)
    |> Enum.join(", ")
  end

end
