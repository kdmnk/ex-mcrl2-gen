defmodule Commands.If do
  defstruct [:condition, :then, :else]


  def writeEx(%Gen.GenState{} = state, %Commands.If{} = cmd) do
    Gen.GenEx.writeBlock(state, "state = if (#{Gen.GenEx.stringifyAST(cmd.condition, true)}) do", fn s ->
      Gen.GenEx.writeCmds(s, cmd.then)
      Gen.Helpers.writeLn(s, "state")
      Gen.Helpers.writeLn(s, "else", -1)
      Gen.GenEx.writeCmds(s, cmd.else)
      Gen.Helpers.writeLn(s, "state")
    end)
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.If{} = cmd) do
    Gen.Helpers.writeLn(state, "((#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.then)
    Gen.Helpers.writeLn(state, ")")
    Gen.Helpers.writeLn(state, "<> (")
    Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.else)
    Gen.Helpers.writeLn(state, "))")
  end

end
