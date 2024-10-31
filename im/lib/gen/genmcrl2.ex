defmodule Im.Gen.GenMcrl2 do

  def main() do
    folder = "./generated/asd"
    :ok = File.mkdir_p(folder)

    conf = Conf.getConf()["asd"]
    run(folder, conf)
  end

  def run(folder, %{:messageType => messageType, :processes => processes}) do
    state = Im.Gen.GenState.new("#{folder}/specs.mcrl2")
    IO.inspect(state.indentation)
    Im.Gen.Helpers.writeLn(state, "sort MessageType = #{messageType};")
    Im.Gen.Helpers.writeLn(state, "sort Pid = Nat;")
    Im.Gen.Helpers.writeLn(state, "act")
    Im.Gen.Helpers.writeLn(state, "sendMessage, receiveMessage, networkReceiveMessage, networkSendMessage, outgoingMessage, incomingMessage: Nat # Nat # MessageType;", +1)
    Im.Gen.Helpers.writeLn(state, "proc")
    processes
    |> Enum.map(fn (x) -> Im.Process.writeMcrl2(x, %{state | indentation: state.indentation+1}) end)

    writeNetwork(state)
    writeInit(state, processes)

    File.close(state.file)
  end


  def writeCmds(state, cmds, separator \\ "."), do:
    Im.Gen.Helpers.join(
      state,
      fn (cmd) -> Im.Commands.writeMcrl2(state, cmd) end,
      cmds,
      separator
    )

  defp writeNetwork(state) do
    Im.Gen.Helpers.writeLn(state, "Network = sum msg, p1, p2: Nat . networkReceiveMessage(p1, p2, msg) . networkSendMessage(p2, p1, msg) . Network() ;", 1)
  end

  defp writeInit(file, processes) do

    Im.Gen.Helpers.writeLn(file, "init", 0)
    Im.Gen.Helpers.writeLn(file, "allow({outgoingMessage, incomingMessage},", 1)
    Im.Gen.Helpers.writeLn(file, "comm({sendMessage|networkReceiveMessage -> outgoingMessage, networkSendMessage|receiveMessage -> incomingMessage},", 2)
    pids = Enum.reduce(processes, %{}, fn p, acc ->
      Map.put(acc, p.identifier, :rand.uniform(10000))
    end)

    Im.Gen.Helpers.writeLn(file, "", 2, "")
    for p <- processes do
      Im.Gen.Helpers.write(file, "#{p.identifier}(#{pids[p.identifier]}")
      for s <- Keyword.values(p.state) do
        Im.Gen.Helpers.write(file, ", #{initialState(s, pids)}")
      end
      Im.Gen.Helpers.write(file, ") || ")
    end
    Im.Gen.Helpers.write(file, "Network", "\n")
    Im.Gen.Helpers.writeLn(file, "));", 0)
  end

  defp initialState(state, pids) do
    case state do
      {:pid, p} -> pids[p]
      p -> p
    end
  end

end
