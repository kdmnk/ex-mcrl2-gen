defmodule GenEx do
  alias Im.SubProcess
  alias Im.Process
  def main() do
    folder = "./generated/asd"
    :ok = File.mkdir_p(folder)

    conf = Conf.getConf()["asd"]
    run(folder, conf)
  end

  def run(folder, %{:processes => all_process}) do

    processes = Enum.filter(all_process, fn
      %Process{} -> true
     _ -> false
    end)

    for %Process{identifier: id} = p <- processes do
      state = Im.Gen.GenState.new("#{folder}/#{p.identifier}.ex")

      subprocesses = Enum.filter(all_process, fn
        %SubProcess{process: ^id} -> true
        _ -> false
      end)

      Process.writeEx(state, p, subprocesses)

      File.close(state.file)
    end

    state = Im.Gen.GenState.new("#{folder}/Main.ex")
    writeBlock(state, "defmodule Main do", fn s ->
      writeBlock(s, "def run() do", fn s ->
        initProcesses(s, processes, [])
      end)

      # choices = Im.Gen.Helpers.getNonDeterministicChoices()
      # Enum.map(choices, fn c ->
      #   writeBlock(s, "def #{c}(module, state) do", fn s ->
      #     Im.Gen.Helpers.writeLn(s, "#TODO: return value")
      #     Im.Gen.Helpers.writeLn(s, "true")
      #   end)
      # end)
    end)
  end

  def writeCmds(_, []), do: IO.puts("")
  def writeCmds(state, [cmd | cmds]) do
    Im.Commands.writeEx(state, cmd)
    writeCmds(state, cmds)
  end

  defp initProcesses(_, [], _), do: IO.puts("")
  defp initProcesses(state, [p | processes], initialised) do
    state = %{state | module_name: "Main"}
    if Enum.all?(Keyword.values(p.state), fn {:pid, name} -> String.replace_prefix(to_string(name), "Elixir.", "") in initialised; _ -> true end) do
      writeLog(state, "starting #{p.identifier}")
      Im.Gen.Helpers.writeLn(state, "#{Im.Gen.Helpers.pidName(p.identifier)} = #{p.identifier}.start(#{Im.Process.statePidNamesStr(p)})")
      writeLog(state, "#{p.identifier} started with PID \#{inspect(#{Im.Gen.Helpers.pidName(p.identifier)})}")
      initProcesses(state, processes, [p.identifier | initialised])
    else
      initProcesses(state, processes ++ [p], initialised)
    end
  end

  def writeLog(%Im.Gen.GenState{} = state, str, indentation \\ 0) do
    Im.Gen.Helpers.writeLn(state, "IO.puts(\"#{state.module_name}: #{str}\")", indentation)
  end

  def writeBlock(%Im.Gen.GenState{} = state, str, child) do
    Im.Gen.Helpers.writeLn(state, str)
    child.(Im.Gen.GenState.indent(state))
    Im.Gen.Helpers.writeLn(state, "end\n")
  end
end
