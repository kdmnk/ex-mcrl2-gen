defmodule GenMcrl2 do
  def run(folder, %{:messageType => messageType, :processes => processes}) do
    {:ok, file} = File.open("#{folder}/specs.mcrl2", [:write])
    Helpers.writeLn(file, "sort MessageType = #{messageType};", 0)
    Helpers.writeLn(file, "sort Pid = Nat;", 0)
    Helpers.writeLn(file, "act", 0)
    Helpers.writeLn(file, "sendMessage, receiveMessage, networkReceiveMessage, networkSendMessage, outgoingMessage, incomingMessage: Nat # Nat # MessageType;", 1)
    Helpers.writeLn(file, "proc", 0)
    for p <- processes do
      Helpers.writeLn(file, "#{p[:name]}(#{getState(p[:state])}) = ", 1, "")
      writeCmds(file, p[:run], ["pid" | Map.keys(p[:state])])
      Helpers.write(file, "#{p[:name]}();", "\n")
    end

    writeNetwork(file)
    writeInit(file, processes)

    File.close(file)
  end

  defp getState(state) do
    extState = Map.put(state, "pid", "Pid") # add own pid
    extState
    |> Map.keys()
    |> Enum.map(fn s -> "#{s}: #{typeToMcrl2(extState[s])}" end)
    |> Enum.join(", ")
  end

  defp writeCmds(_, [], _), do: IO.puts("")
  defp writeCmds(file, [cmd | cmds], boundedVars) do
    case cmd do
      {:send, to: to, message: message} ->
        Helpers.write(file, "sendMessage(pid, #{to}, #{message}) . ")
        writeCmds(file, cmds, boundedVars)
      {:receive} ->
        pidVar = getNextVar()
        messageVar = getNextVar()
        Helpers.write(file, "sum #{pidVar}: Pid . sum #{messageVar}: MessageType . ")
        writeCmds(file, [{:receive, from: pidVar, message: messageVar} | cmds], [messageVar | [pidVar | [boundedVars]]])
      {:receive, message: m} ->
        pidVar = getNextVar()
        Helpers.write(file, "sum #{pidVar}: Pid . ")
        writeCmds(file, [{:receive, from: pidVar, message: m} | cmds], [pidVar | boundedVars])
      {:receive, from: from} ->
        messageVar = getNextVar()
        Helpers.write(file, "sum #{messageVar} : MessageType .")
        writeCmds(file, [{:receive, from: from, message: messageVar} | cmds], [messageVar | boundedVars])
      {:receive, from: from, message: m} ->
        cond do
          !(m in boundedVars || is_number(m)) ->
            Helpers.write(file, "sum #{m} : MessageType .")
            writeCmds(file, [{:receive, from: from, message: m} | cmds], [m | boundedVars])
         !(from in boundedVars) ->
            Helpers.write(file, "sum #{from} : Pid .")
            writeCmds(file, [{:receive, from: from, message: m} | cmds], [from | boundedVars])
          true ->
            Helpers.write(file, "receiveMessage(pid, #{from}, #{m}) . ")
            writeCmds(file, cmds, boundedVars)
        end

    end
  end

  defp getNextVar() do
    if Process.whereis(:randomAgent) == nil do
      {:ok, randomAgent} = Agent.start_link(fn -> 0  end)
      Process.register(randomAgent, :randomAgent)
    end
    nextId = Agent.get_and_update(:randomAgent, fn i -> {i, i + 1} end)
    "_v#{nextId}"
  end

  defp writeNetwork(file) do
    Helpers.writeLn(file, "Network = sum msg, p1, p2: Nat . networkReceiveMessage(p1, p2, msg) . networkSendMessage(p2, p1, msg) . Network() ;", 1)
  end

  defp writeInit(file, processes) do

    Helpers.writeLn(file, "init", 0)
    Helpers.writeLn(file, "allow({outgoingMessage, incomingMessage},", 1)
    Helpers.writeLn(file, "comm({sendMessage|networkReceiveMessage -> outgoingMessage, networkSendMessage|receiveMessage -> incomingMessage},", 2)
    pids = Enum.reduce(processes, %{}, fn p, acc ->
      Map.put(acc, p[:name], :rand.uniform(10000))
    end)

    Helpers.writeLn(file, "", 2, "")
    for p <- processes do
      Helpers.write(file, "#{p[:name]}(#{pids[p[:name]]}")
      for s <- Map.values(p[:state]) do
        Helpers.write(file, ", #{initialState(s, pids)}")
      end
      Helpers.write(file, ") || ")
    end
    Helpers.write(file, "Network", "\n")
    Helpers.writeLn(file, "));", 0)
  end

  defp initialState(state, pids) do
    case state do
      {:pid, p} -> pids[p]
      p -> p
    end
  end


  defp typeToMcrl2(type) do
    case type do
      {:pid, _} -> "Pid"
      p -> p
    end
  end
end
