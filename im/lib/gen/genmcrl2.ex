defmodule Im.Gen.GenMcrl2 do

  def main() do
    folder = "./generated/asd"
    :ok = File.mkdir_p(folder)

    conf = Conf.getConf()["asd"]
    run(folder, conf)
  end

  def run(folder, %{:messageType => messageType, :processes => processes}) do
    state = Im.Gen.GenState.new("#{folder}/specs.mcrl2")
    Im.Gen.Helpers.writeLn(state, "sort MessageType = #{messageType};")
    Im.Gen.Helpers.writeLn(state, "sort Pid = Nat;")
    Im.Gen.Helpers.writeLn(state, "sort Message = struct Message(senderID: Pid, receiverID: Pid, message: MessageType);")
    Im.Gen.Helpers.writeLn(state, "act")
    Im.Gen.Helpers.writeLn(state, "sendMessage, receiveMessage, networkReceiveMessage, networkSendMessage, outgoingMessage, incomingMessage: Nat # Nat # MessageType;", +1)
    Im.Gen.Helpers.writeLn(state, "proc")
    processes
    |> Enum.map(fn
      (%Im.Process{} = x) -> Im.Process.writeMcrl2(x, %{state | indentation: state.indentation+1})
      (%Im.SubProcess{} = x) -> Im.SubProcess.writeMcrl2(x, %{state | indentation: state.indentation+1})
    end)

    writeNetwork(state)
    writeInit(state, Enum.filter(processes, fn
      (%Im.Process{}) -> true
      _ -> false
      end))

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
    Im.Gen.Helpers.writeLn(state, "Network(msgs: FSet(Message)) =", 1)
    Im.Gen.Helpers.writeLn(state, "sum sender : Pid,  receiver : Pid, msg: MessageType . networkReceiveMessage(sender, receiver, msg)", 2)
    Im.Gen.Helpers.writeLn(state, ". Network(msgs = msgs + {Message(sender, receiver, msg)})", 2)
    Im.Gen.Helpers.writeLn(state, "+", 2)
    Im.Gen.Helpers.writeLn(state, "sum msg: Message . (msg in msgs) -> networkSendMessage(receiverID(msg), senderID(msg), message(msg))", 2)
    Im.Gen.Helpers.writeLn(state, ". Network(msgs = msgs - {msg});", 2)
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
    Im.Gen.Helpers.write(file, "Network({})", "\n")
    Im.Gen.Helpers.writeLn(file, "));", 0)
  end

  defp initialState(state, pids) do
    case state do
      {:pid, p} -> pids[p]
      p -> p
    end
  end

  def stringifyAST(ast) do
    case ast do
      {op, _pos, [left, right]} when op in [:==, :>, :<, :-, :in] -> "#{stringifyAST(left)} #{op} #{stringifyAST(right)}"
      [{op, _pos, [left, right]}] when op in [:==, :>, :<, :-, :in] -> "(#{stringifyAST(left)} #{op} #{stringifyAST(right)})"
      [{:|, _pos, [left, right]}] -> "#{stringifyAST(left)} |> #{stringifyAST(right)}"
      {:or, _pos, [left, right]} -> "#{stringifyAST(left)} || #{stringifyAST(right)}"
      {:and, _pos, [left, right]} -> "#{stringifyAST(left)} && #{stringifyAST(right)}"
      {:!, _pos, right} -> "!#{stringifyAST(right)}"
      {var, _pos, nil} -> var
      var when is_atom(var) -> var
      int when is_integer(int) -> int
      [] -> "[]"
    end
  end

end
