defmodule Im.Commands.If do
  defstruct [:condition, :then, :else]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.If{} = cmd) do
    GenEx.writeBlock(state, "if (#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) do", fn s ->
      GenEx.writeCmds(s, cmd.then)
      Im.Gen.Helpers.writeLn(s, "else", -1)
      GenEx.writeCmds(s, cmd.else)
    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.If{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.then)
    Im.Gen.Helpers.writeLn(state, ")")
    Im.Gen.Helpers.writeLn(state, "<> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.then)
    Im.Gen.Helpers.writeLn(state, ")")
  end

end
