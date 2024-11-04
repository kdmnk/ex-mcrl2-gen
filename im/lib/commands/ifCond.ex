defmodule Im.Commands.IfCond do
  defstruct [:condition, :body]


  def writeErl(%Im.Gen.GenState{} = state, %Im.Commands.IfCond{} = cmd, log) do
    Im.Gen.Helpers.write(state, "when #{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)} ->", "\n")

    newState = Im.Gen.GenState.indent(state)
    GenEx.writeLog(newState, log <> " and '#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}' holds", 0)
    GenEx.writeCmds(newState, cmd.body)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.IfCond{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{Im.Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Im.Gen.Helpers.writeLn(state, ")")
  end



end
