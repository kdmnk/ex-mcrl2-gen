defmodule Im.Commands.If do
  defstruct [:condition, :then, :else]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.If{} = cmd) do
    GenEx.writeBlock(state, "state = if (#{GenEx.stringifyAST(cmd.condition, true)}) do", fn s ->
      GenEx.writeCmds(s, cmd.then)
      Im.Gen.Helpers.writeLn(s, "state")
      Im.Gen.Helpers.writeLn(s, "else", -1)
      GenEx.writeCmds(s, cmd.else)
      Im.Gen.Helpers.writeLn(s, "state")
    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.If{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.then)
    Im.Gen.Helpers.writeLn(state, ")")
    Im.Gen.Helpers.writeLn(state, "<> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.else)
    Im.Gen.Helpers.writeLn(state, ")")
  end

end
