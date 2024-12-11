defmodule Gen.GenMcrl2 do
  alias Processes.Process
  alias Processes.SubProcess

  def main() do
    name = "twoPhasedCommitMultiple"
    folder = "./generated/#{name}/mcrl2"
    :ok = File.mkdir_p(folder)

    conf = Conf.getConf(Protocols.TwoPhasedCommitMultiple)
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
    randomPids = Enum.map(processes, fn p ->
      case p.quantity do
        x when x > 1 ->
          pids = Enum.join(Enum.map(1..x, fn _ -> :rand.uniform(100) end), ", ")
          "map #{p.identifier}_PID : List(Pid);\neqn #{p.identifier}_PID = [#{pids}];\n"
        _ -> "map #{p.identifier}_PID : Pid;\neqn #{p.identifier}_PID = #{:rand.uniform(100)};"
      end
    end)
    |> Enum.join("")

    """
    sort Pid = Nat;
    sort MessageType = #{messageType};
    sort Message = struct Message(senderID: Pid, receiverID: Pid, message: MessageType);

    map LOSSY_NETWORK : Bool;
    eqn LOSSY_NETWORK = #{lossyNetwork};

    #{randomPids}

    map SplitBroadcastedMessages: Pid # List(Pid) # MessageType -> FSet(Message);
    var v_sender: Pid;
	      v_receivers: List(Pid);
        v_message: MessageType;
    eqn SplitBroadcastedMessages(v_sender, v_receivers, v_message) =
        SplitBroadcastedMessagesHelper(v_sender, v_receivers, v_message, {});
    map SplitBroadcastedMessagesHelper: Pid # List(Pid) # MessageType # FSet(Message) -> FSet(Message);
    var v_sender: Pid;
        v_receivers: List(Pid);
        v_message: MessageType;
        v_msgs: FSet(Message);
    eqn ((# v_receivers) == 0) -> SplitBroadcastedMessagesHelper(v_sender, v_receivers, v_message, v_msgs) = v_msgs;
        ((# v_receivers) > 0)  -> SplitBroadcastedMessagesHelper(v_sender, v_receivers, v_message, v_msgs) =
                         SplitBroadcastedMessagesHelper(v_sender, tail(v_receivers), v_message, v_msgs
                         + {Message(v_sender, head(v_receivers), v_message)} );


    act
      sendMessage, receiveMessage, networkReceiveMessage, networkSendMessage, outgoingMessage, incomingMessage: Pid # Pid # MessageType;
      broadcastMessages, networkBroadcastMessages, broadcast: Pid # List(Pid) # MessageType;
      lose;
    proc
    """
  end

  defp getNetworkString(), do: """
    Network(msgs: FSet(Message)) =
      (sum sender : Pid, msg: MessageType . (
        (sum receiver : Pid .
          networkReceiveMessage(sender, receiver, msg) .
          Network(msgs = msgs + {Message(sender, receiver, msg)})
        )
        +
        (sum receivers: List(Pid) .
          networkBroadcastMessages(sender, receivers, msg) .
          Network(msgs = msgs + SplitBroadcastedMessages(sender, receivers, msg)))
       ))
       +
       (sum msg: Message . (msg in msgs) ->
         (networkSendMessage(receiverID(msg), senderID(msg), message(msg))
           + ((LOSSY_NETWORK) -> lose)
         ) . Network(msgs = msgs - {msg}));
    """

  defp getInitString(processes) do
    pr = processes
      |> Enum.map(fn p ->
        case p.quantity do
          x when x > 1 ->
            Enum.map(0..(x-1), fn q ->
              "#{p.identifier}(" <>
              (["#{p.identifier}_PID . #{q}" | Enum.map(Keyword.values(p.state), fn
                {:pid, v} -> "#{v}_PID"
                {:list, {:pid, v}} -> "#{v}_PID"
               end)]
              |> Enum.join(", "))
              <> ")"
            end)
            |> Enum.join(" || ")
          _ -> "#{p.identifier}(" <>
              (["#{p.identifier}_PID" | Enum.map(Keyword.values(p.state), fn
                {:pid, v} -> "#{v}_PID"
                {:list, {:pid, v}} -> "#{v}_PID"
               end)]
              |> Enum.join(", "))
              <> ")"
        end

      end)
      |> Enum.join(" || ")

    """
    init
      allow({outgoingMessage, incomingMessage, broadcast, lose},
      comm({
        sendMessage|networkReceiveMessage -> outgoingMessage,
        networkSendMessage|receiveMessage -> incomingMessage,
        broadcastMessages|networkBroadcastMessages -> broadcast
      },
        #{pr} || Network({})
      )
    );
    """
  end

  def stringifyAST(ast) do
    case ast do
      {op, _pos, [left, right]} when op in [:==, :>, :<, :-, :in] -> "#{stringifyAST(left)} #{op} #{stringifyAST(right)}"
      {:|, _pos, [left, right]} -> "#{stringifyAST(left)} |> #{stringifyAST(right)}"
      {:or, _pos, [left, right]} -> "#{stringifyAST(left)} || #{stringifyAST(right)}"
      {:and, _pos, [left, right]} -> "#{stringifyAST(left)} && #{stringifyAST(right)}"
      {:!, _pos, arg} -> "!#{stringifyAST(arg)}"
      {:length, _pos, arg} -> "# #{stringifyAST(arg)}"
      [a | b] when b != [] -> "(#{stringifyAST(a)}, #{stringifyAST(b)})"
      [a] -> "(#{stringifyAST(a)})"
      {var, _pos, nil} -> var
      var when is_atom(var) -> var
      int when is_integer(int) -> int
      [] -> "[]"
    end
  end

end
