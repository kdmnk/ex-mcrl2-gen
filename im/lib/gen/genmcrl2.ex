defmodule Gen.GenMcrl2 do
  alias Processes.Process
  alias Processes.SubProcess

  def main() do
    folder = "./generated/asd"
    :ok = File.mkdir_p(folder)

    conf = Conf.getConf()["asd"]
    run(folder, conf)
  end

  def run(folder, %{:messageType => messageType, :lossyNetwork => lossyNetwork, :processes => all_process}) do
    state = Gen.GenState.new("#{folder}/specs.mcrl2")
    processes = Enum.filter(all_process, fn
      %Process{} -> true
     _ -> false
    end)

    Gen.Helpers.write(state, getDeclarationsString(messageType, lossyNetwork, processes))

    for %Process{identifier: id} = p <- processes do
      subprocesses = Enum.filter(all_process, fn
        %SubProcess{process: ^id} -> true
        _ -> false
      end)
      module_state = Keyword.merge([pid: "Pid"], p.state)
      state = %{state | module_name: p.identifier, module_state: module_state, indentation: state.indentation+1}
      Process.writeMcrl2(p, state)
      subprocesses
      |> Enum.map(fn x -> SubProcess.writeMcrl2(x, state) end)
    end

    Gen.Helpers.write(state, getNetworkString())
    Gen.Helpers.write(state, getInitString(processes))

    File.close(state.file)
  end


  def writeCmds(state, cmds, separator \\ "."), do:
    Gen.Helpers.join(
      state,
      fn (cmd) -> Commands.Command.writeMcrl2(state, cmd) end,
      cmds,
      separator
    )

  defp getDeclarationsString(messageType, lossyNetwork, processes) do
    randomPids = Enum.map(processes, fn p -> "map #{p.identifier}_PID : Pid;\neqn #{p.identifier}_PID = #{:rand.uniform(100)};\n" end)

    """
    sort Pid = Nat;
    sort MessageType = #{messageType};
    sort Message = struct Message(senderID: Pid, receiverID: Pid, message: MessageType);

    map LOSSY_NETWORK : Bool;
    eqn LOSSY_NETWORK = #{lossyNetwork};

    #{Enum.join(randomPids, "")}

    act
      sendMessage, receiveMessage, networkReceiveMessage, networkSendMessage, outgoingMessage, incomingMessage: Nat # Nat # MessageType;
      lose;
    proc
    """
  end

  defp getNetworkString(), do: """
    Network(msgs: FSet(Message)) =
      (sum sender : Pid,  receiver : Pid, msg: MessageType .
        networkReceiveMessage(sender, receiver, msg) .
        Network(msgs = msgs + {Message(sender, receiver, msg)})
      )
      +
      (sum msg: Message . (msg in msgs) ->
        (networkSendMessage(receiverID(msg), senderID(msg), message(msg))
          + ((LOSSY_NETWORK) -> lose)
        ) . Network(msgs = msgs - {msg}));
    """

  defp getInitString(processes) do
    pr = processes
      |> Enum.map(fn p ->
        "#{p.identifier}(" <>
        (["#{p.identifier}_PID" | Enum.map(Keyword.values(p.state), fn {:pid, v} -> "#{v}_PID" end)]
        |> Enum.join(", "))
        <> ")"
      end)
      |> Enum.join(" || ")

    """
    init
      allow({outgoingMessage, incomingMessage, lose},
      comm({sendMessage|networkReceiveMessage -> outgoingMessage, networkSendMessage|receiveMessage -> incomingMessage},
        #{pr} || Network({})
      )
    );
    """
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
