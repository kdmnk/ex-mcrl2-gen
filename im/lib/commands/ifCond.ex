defmodule Im.Commands.IfCond do
  defstruct [:condition, :body]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.IfCond{} = cmd) do
    GenEx.writeBlock(state, "if (#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) do", fn s ->
      GenEx.writeCmds(s, cmd.body)
    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.IfCond{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Im.Gen.Helpers.writeLn(state, ")")
  end

end
