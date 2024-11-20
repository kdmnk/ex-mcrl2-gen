defmodule Im.Commands.ReceiveCase do
  defstruct [:condition, :body]

  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.ReceiveCase{} = cmd, %Im.Commands.Receive{} = receiveCmd) do
    GenEx.writeBlock(state, "def handle_cast({#{receiveCmd.from}, #{receiveCmd.value}}, state) when #{GenEx.stringifyAST(cmd.condition)} do", fn s ->
      GenEx.writeLog(s, "received \#{inspect(#{receiveCmd.value})} from \#{inspect(#{receiveCmd.from})}" <> " and '#{GenEx.stringifyAST(cmd.condition)}' holds", 0)
      vars = Enum.map(s.bounded_vars, fn var -> ":#{var} => #{var}" end)
      Im.Gen.Helpers.writeLn(s, "state = %{#{Enum.join(vars, ", ")}}")
      GenEx.writeCmds(s, cmd.body)
      case Enum.at(cmd.body, -1) do
        %Im.Commands.Call{} -> ""
        _ -> Im.Gen.Helpers.writeLn(s, "{:noreply, state}")
      end

    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.ReceiveCase{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Im.Gen.Helpers.writeLn(state, ")")
  end

end
