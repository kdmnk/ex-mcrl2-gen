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
        {:receive, from: :serverPid, message: 2, child: []}
      ]
    },
    %{
      :name => "Mach",
      :state => %{},
      :run => [
        {:receive, message: "m", child: [
            {:send, to: :p, message: "m+1"}
        ]},

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
      for r <- p[:run] do
        writeCmd(file, r, ["pid" | Map.keys(p[:state])])
      end
      IO.binwrite(file, "#{p[:name]}();\n")
    end

    genNetwork(file)
    genInit(file, processes)

    File.close(file)
  end

  defp writeCmd(file, cmd, boundedVars) do
    case cmd do
      {:send, to: to, message: message} ->
        IO.binwrite(file, "sendMessage(pid, #{to}, #{message}) . ")
      {:receive, from: from, message: m, child: child} ->
        if m in boundedVars || is_number(m) do
          IO.binwrite(file, "receiveMessage(pid, #{from}, #{m}) . ")
          for c <- child do
            writeCmd(file, c, boundedVars)
          end
        else
          IO.binwrite(file, "sum #{m} : MessageType .")
          writeCmd(file, {:receive, from: from, message: m, child: child}, [m | boundedVars])
        end
      {:receive, message: m, child: child} ->
        IO.binwrite(file, "sum p: Pid . ")
        writeCmd(file, {:receive, from: "p", message: m, child: child}, ["p" | boundedVars])

    end
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
