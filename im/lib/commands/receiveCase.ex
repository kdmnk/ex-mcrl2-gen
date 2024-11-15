defmodule Im.Commands.ReceiveCase do
  defstruct [:condition, :body]

  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.ReceiveCase{} = cmd, %Im.Commands.Receive{} = receiveCmd) do
    GenEx.writeBlock(state, "def handle_cast({#{receiveCmd.from}, #{receiveCmd.value}}, {state, waiting}) when #{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)} do", fn s ->
      GenEx.writeLog(s, "received \#{inspect(#{receiveCmd.value})} from \#{inspect(#{receiveCmd.from})}" <> " and '#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}' holds", 0)
      GenEx.writeCmds(s, cmd.body)
      Im.Gen.Helpers.writeLn(s, "{:noreply, {state, waiting}}")
    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.ReceiveCase{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Im.Gen.Helpers.writeLn(state, ")")
  end

end
