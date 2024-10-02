defmodule Gen do
  def run() do
    messageType = :Nat
    processes = [%{
      :name => "User",
      :state => %{
        :serverPid => {:pid, "Mach"}
      },
      :run => [
        {:send, to: :serverPid, message: 1},
        {:receive, from: :serverPid}
      ]
    },
    %{
      :name => "Mach",
      :state => %{},
      :run => [
        {:receive, from: "p", message: "m"},
        {:send, to: "p", message: "m+1"}
      ]
    }]

    gen(processes, messageType)
  end

  def gen(processes, messageType) do
    {:ok, file} = File.open("gen.mcrl2", [:write])
    IO.binwrite(file, "sort MessageType = #{messageType};\nsort Pid = Nat;")
    IO.binwrite(file, "\nact\n  sendMessage, receiveMessage, networkReceiveMessage, networkSendMessage, outgoingMessage, incomingMessage: Nat # Nat # MessageType;")
    IO.binwrite(file, "\nproc\n")
    for p <- processes do
      IO.binwrite(file, "  #{p[:name]}(pid: Pid")
      for s <- Map.keys(p[:state]) do
        IO.binwrite(file, ", #{s}: #{typeToMcrl2(p[:state][s])}")
      end
      IO.binwrite(file, ") = ")
      writeCmds(file, p[:run], ["pid" | Map.keys(p[:state])])
      IO.binwrite(file, "#{p[:name]}();\n")
    end

    genNetwork(file)
    genInit(file, processes)

    File.close(file)
  end

  defp writeCmds(_, [], _), do: IO.puts("")
  defp writeCmds(file, [cmd | cmds], boundedVars) do
    case cmd do
      {:send, to: to, message: message} ->
        IO.binwrite(file, "sendMessage(pid, #{to}, #{message}) . ")
        writeCmds(file, cmds, boundedVars)
      {:receive, message: m} ->
        pidVar = getNextVar()
        IO.binwrite(file, "sum #{pidVar}: Pid . ")
        writeCmds(file, [{:receive, from: pidVar, message: m} | cmds], [pidVar | boundedVars])
      {:receive, from: from} ->
        messageVar = getNextVar()
        IO.binwrite(file, "sum #{messageVar} : MessageType .")
        writeCmds(file, [{:receive, from: from, message: messageVar} | cmds], [messageVar | boundedVars])
      {:receive, from: from, message: m} ->
        cond do
          !(m in boundedVars || is_number(m)) ->
            IO.binwrite(file, "sum #{m} : MessageType .")
            writeCmds(file, [{:receive, from: from, message: m} | cmds], [m | boundedVars])
         !(from in boundedVars) ->
            IO.binwrite(file, "sum #{from} : Pid .")
            writeCmds(file, [{:receive, from: from, message: m} | cmds], [from | boundedVars])
          true ->
            IO.binwrite(file, "receiveMessage(pid, #{from}, #{m}) . ")
            writeCmds(file, cmds, boundedVars)
        end

    end
  end

  defp getNextVar() do
    if Process.whereis(:randomAgent) == nil do
      randomAgent = Agent.start_link(fn -> 0  end)
      Process.register(randomAgent, :randomAgent)
    end
    nextId = Agent.get_and_update(:randomAgent, fn i -> {i, i + 1} end)
    "_v#{nextId}"
  end

  defp genNetwork(file) do
    IO.binwrite(file, "  Network = sum msg, p1, p2: Nat . networkReceiveMessage(p1, p2, msg) . networkSendMessage(p2, p1, msg) . Network() ;")
  end

  defp genInit(file, processes) do

    IO.binwrite(file, "\ninit\n allow({outgoingMessage, incomingMessage},\n  comm({sendMessage|networkReceiveMessage -> outgoingMessage, networkSendMessage|receiveMessage -> incomingMessage},\n  ")
    pids = Enum.reduce(processes, %{}, fn p, acc ->
      Map.put(acc, p[:name], :rand.uniform(10000))
    end)

    for p <- processes do
      IO.binwrite(file, "#{p[:name]}(#{pids[p[:name]]}")
      for s <- Map.values(p[:state]) do
        IO.binwrite(file, ", #{initialState(s, pids)}")
      end
      IO.binwrite(file, ") || ")
    end
    IO.binwrite(file, "Network\n));")
  end

  defp initialState(state, pids) do
    case state do
      {:pid, p} -> pids[p]
      p -> p
    end
  end


  defp typeToMcrl2(type) do
    case type do
      {:pid, _} -> "Nat"
    end
  end
end
