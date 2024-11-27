defmodule Commands.ReceiveCase do
  defstruct [:condition, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.ReceiveCase{} = cmd, %Commands.Receive{} = receiveCmd) do
    Gen.GenEx.writeBlock(state, "def handle_cast({#{receiveCmd.from}, #{receiveCmd.value}}, state) when #{Gen.GenEx.stringifyAST(cmd.condition)} do", fn s ->
      Gen.GenEx.writeLog(s, "received \#{inspect(#{receiveCmd.value})} from \#{inspect(#{receiveCmd.from})}" <> " and '#{Gen.GenEx.stringifyAST(cmd.condition)}' holds", 0)
      Gen.Helpers.writeLn(s, "state = updateState(state, %{:#{receiveCmd.value} => #{receiveCmd.value}, :#{receiveCmd.from} => #{receiveCmd.from}})")
      Gen.GenEx.writeCmds(s, cmd.body)
      Gen.Helpers.writeLn(s, "{:noreply, state}")
    end)
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.ReceiveCase{} = cmd) do
    Gen.Helpers.writeLn(state, "(#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Gen.Helpers.writeLn(state, ")")
  end

end
