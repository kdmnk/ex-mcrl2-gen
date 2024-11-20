defmodule Im.Process do
  alias Im.Commands.Receive
  alias Im.Gen.GenMcrl2

  defstruct [:identifier, :state, :run, :test]

  def writeMcrl2(%Im.Process{} = p, state) do
    Im.Gen.Helpers.writeLn(state, "#{p.identifier}(#{Im.Gen.Helpers.getState(p.state)}) = ")

    GenMcrl2.writeCmds(Im.Gen.GenState.indent(Im.Gen.GenState.addBoundVars(state, ["pid" | stateList(p)])), p.run)

    Im.Gen.Helpers.writeLn(state, ". #{p.identifier}();", +1)
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.Gen.GenState{} = stateApi, %Im.Process{} = p, subprocesses) do

    choices = getCommands(Im.Commands.Choice, p.run, [])

    GenEx.writeBlock(stateApi, "defmodule #{p.identifier}Api do", fn s ->
      s = %{s |
        module_name: p.identifier <> "Api",
      }

      Im.Gen.Helpers.writeLn(s, "use GenServer\n")
      GenEx.writeBlock(s, "defmodule InitState do", fn s ->
        Im.Gen.Helpers.writeLn(s, "defstruct [:pid]")
      end)

      Enum.map(choices, fn cmd ->
        GenEx.writeBlock(s, "defmodule Choice#{cmd.label}State do", fn s ->
          Im.Gen.Helpers.writeLn(s, "defstruct [:choice, :vars]")
        end)
      end)

      GenEx.writeBlock(s, "def init(#{stateStr(p)}) do", fn s ->
        GenEx.writeBlock(s, "if Process.whereis(#{p.identifier}) do", fn s ->
          Im.Gen.Helpers.writeLn(s, "GenServer.stop(#{p.identifier})")
        end)
        Im.Gen.Helpers.writeLn(s, "{:ok, pid} = GenServer.start_link(#{p.identifier}, %{#{stateMap(p)}}, name: #{p.identifier})")
        Im.Gen.Helpers.writeLn(s, "GenServer.start_link(__MODULE__, [], name: __MODULE__)")
        Im.Gen.Helpers.writeLn(s, "%InitState{pid: pid}")
      end)

      GenEx.writeBlock(s, "def start(%InitState{}) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "GenServer.cast(#{p.identifier}, :start)")
      end)

      if choices != [] do
        GenEx.writeBlock(s, "def wait() do", fn s ->
          Im.Gen.Helpers.writeLn(s, "GenServer.call(__MODULE__, :wait)")
        end)

        Enum.map(choices, fn cmd ->
          GenEx.writeBlock(s, "def choose#{cmd.label}(%Choice#{cmd.label}State{}, choice) do", fn s ->
            Im.Gen.Helpers.writeLn(s, "GenServer.cast(#{p.identifier}, {:#{cmd.label}, choice})")
          end)
        end)
      end

      GenEx.writeBlock(s, "def init(_) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "{:ok, {%{}, nil}}")
      end)

      if choices != [] do
        GenEx.writeBlock(s, "def handle_call(:wait, from, {choiceState, true}) do", fn s ->
          GenEx.writeLog(s, "Started waiting. Replying with already updated state.")
          Im.Gen.Helpers.writeLn(s, "{:reply, choiceState, {%{}, nil}}")
        end)

        GenEx.writeBlock(s, "def handle_call(:wait, from, {state, nil}) do", fn s ->
          GenEx.writeLog(s, "Started waiting.")
          Im.Gen.Helpers.writeLn(s, "{:noreply, {state, from}}")
        end)


        GenEx.writeBlock(s, "def handle_cast({:new_choice, choiceState},{_, waiting}) do", fn s ->
          GenEx.writeBlock(s, "if waiting do", fn s ->
            GenEx.writeLog(s, "replying to wait")
            Im.Gen.Helpers.writeLn(s, "GenServer.reply(waiting, choiceState)")
            Im.Gen.Helpers.writeLn(s, "{:noreply, {%{}, nil}}")
            Im.Gen.Helpers.writeLn(s, "else", -1)
            Im.Gen.Helpers.writeLn(s, "{:noreply, {choiceState, true}}")
          end)
        end)
      end
    end)


    GenEx.writeBlock(state, "defmodule #{p.identifier} do", fn s ->
      s = %{s |
        bounded_vars: s.bounded_vars ++ Im.Process.stateList(p),
        module_name: p.identifier,
        module_state: Im.Process.stateList(p)}

      Im.Gen.Helpers.writeLn(s, "use GenServer\n")

      GenEx.writeBlock(s, "def init(vars) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "{:ok, vars}")
      end)

      GenEx.writeBlock(s, "def handle_cast(:start, state) do", fn s ->
        Enum.map(p.run, fn cmd ->
          Im.Commands.writeEx(s, cmd)
        end)
      end)

      Enum.map(choices, fn cmd ->
        [case1, case2] = cmd.body
        GenEx.writeBlock(s, "def handle_cast({:#{cmd.label}, true}, state) do", fn s ->
          Im.Commands.writeEx(s, case1)
          Im.Gen.Helpers.writeLn(s, "{:noreply, state}")
        end)
        GenEx.writeBlock(s, "def handle_cast({:#{cmd.label}, false}, state) do", fn s ->
          Im.Commands.writeEx(s, case2)
          Im.Gen.Helpers.writeLn(s, "{:noreply, state}")
        end)
      end)

      all_cmds = Enum.reduce(subprocesses, p.run, fn (s, acc) -> s.run ++ acc end)
      recs = getCommands(Im.Commands.Receive, all_cmds, [])
      Enum.map(recs, fn cmd ->
          Im.Commands.Receive.writeExRecCallback(s, cmd)
      end)

      Enum.map(subprocesses, fn sp ->
        Im.SubProcess.writeEx(s, sp)
      end)
    end)
  end

  # def getAllRcv(%Im.Process{} = p, subprocesses) do
  #  Enum.map(subprocesses, fn sp -> sp.run end)
  #   |> Enum.reduce(p.run, fn s, acc -> s ++ acc end)
  # end

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

  def stateList(%Im.Process{} = p), do: Keyword.keys(p.state)

  def stateStr(%Im.Process{} = p) do
    Keyword.keys(p.state) |> Enum.join(", ")
  end

  def stateMap(%Im.Process{} = p) do
    Keyword.keys(p.state) |> Enum.map(fn s -> ":#{s} => #{s}" end) |> Enum.join(", ")
  end

  def statePidNamesStr(%Im.Process{} = p) do
    Keyword.values(p.state)
    |> Enum.map(fn {:pid, name} -> Im.Gen.Helpers.pidName(name) end)
    |> Enum.join(", ")
  end

end
