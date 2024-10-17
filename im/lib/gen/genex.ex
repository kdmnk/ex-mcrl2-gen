defmodule GenEx do


  def run(folder, %{:processes => processes}) do
    for p <- processes do
      {:ok, file} = File.open("#{folder}/#{p[:name]}.ex", [:write])
      writeBlock(file, "defmodule #{p[:name]} do", fn (indent) ->
        writeBlock(file, "def start(#{writeState(p[:state])}) do", fn (indent) ->
          Helpers.writeLn(file, "spawn(fn -> loop(#{writeState(p[:state])}) end)", indent)
        end, indent)

        writeBlock(file, "defp loop(#{writeState(p[:state])}) do", fn (indent) ->
          writeCmds(file, p[:run], Map.keys(p[:state]), indent, p[:name])
          Helpers.writeLn(file, "loop(#{writeState(p[:state])})", indent)
        end, indent)
      end, 0)

      File.close(file)
    end

    {:ok, file} = File.open("#{folder}/Main.ex", [:write])
    writeBlock(file, "defmodule Main do", fn (indent) ->
      writeBlock(file, "def run() do", fn (indent) ->
        initProcesses(file, processes, [], indent)
      end, indent)
    end, 0)


  end

  defp writeState(state) do
    Map.keys(state) |> Enum.join(", ")
  end

  defp writePidState(state) do
    Map.values(state)
    |> Enum.map(fn {:pid, name} -> pidName(name) end)
    |> Enum.join(", ")
  end

  defp writeCmds(_, [], _, _, _), do: IO.puts("")
  defp writeCmds(file, [cmd | cmds], boundedVars, indent, name) do
    case cmd do
      {:send, to: to, message: message} ->
        writeLog(file, "#{name}: sending \#{inspect(#{message})} to \#{inspect(#{to})}", indent)
        Helpers.writeLn(file, "send(#{to}, {self(), #{message}})", indent)
        writeCmds(file, cmds, boundedVars, indent, name)
      {:receive} ->
        pidVar = getNextVar()
        messageVar = getNextVar()
        writeCmds(file, [{:receive, from: pidVar, message: messageVar} | cmds], [messageVar | boundedVars], indent, name)
      {:receive, message: m} ->
        pidVar = getNextVar()
        writeCmds(file, [{:receive, from: pidVar, message: m} | cmds], boundedVars, indent, name)
      {:receive, from: from} ->
        messageVar = getNextVar()
        writeCmds(file, [{:receive, from: from, message: messageVar} | cmds], [messageVar | boundedVars], indent, name)
      {:receive, from: from, message: m} ->
        writeBlock(file, "receive do", fn (indent) ->
          Helpers.writeLn(file, "{", indent, "")
          if from in boundedVars, do: Helpers.write(file, "^")
          Helpers.write(file, "#{from}, #{m}} ->", "\n")
          writeLog(file, "#{name}: received \#{inspect(#{m})} from \#{inspect(#{from})}", indent + 1)
          writeCmds(file, cmds, boundedVars, indent + 1, name)
        end, indent)
    end
  end

  defp initProcesses(_, [], _,  _), do: IO.puts("")
  defp initProcesses(file, [p | processes], initialised, indent) do
    if Enum.all?(Map.values(p[:state]), fn {:pid, name} -> name in initialised; _ -> true end) do
      writeLog(file, "Main: starting #{p[:name]}", indent)
      Helpers.writeLn(file, "#{pidName(p[:name])} = #{p[:name]}.start(#{writePidState(p[:state])})", indent)
      writeLog(file, "Main: #{p[:name]} started with PID \#{inspect(#{pidName(p[:name])})}", indent)
      initProcesses(file, processes, [p[:name] | initialised], indent)
    else
      initProcesses(file, processes ++ [p], initialised, indent)
    end
  end

  defp pidName(name) do
    String.downcase(name) <> "_pid"
  end

  def writeLog(file, str, indent, ending \\ "\n") do
    Helpers.writeLn(file, "IO.puts(\"#{str}\")", indent, ending)
  end

  defp writeBlock(file, str, child, indent, ending \\ "\n") do
    Helpers.writeLn(file, str, indent)
    child.(indent + 1)
    Helpers.writeLn(file, "end", indent, ending)
  end

  defp getNextVar() do
    nextId = Helpers.getNextId()
    "v#{nextId}"
  end

end
