defmodule Im.Commands.IfCond do
  defstruct [:condition, :body]


  def writeErl(%Im.Gen.GenState{} = state, %Im.Commands.IfCond{} = cmd, log) do
    Im.Gen.Helpers.write(state, "when #{stringifyAST(cmd.condition)} ->", "\n")

    newState = Im.Gen.GenState.indent(state)
    GenEx.writeLog(newState, log <> " and '#{stringifyAST(cmd.condition)}' holds", 0)
    GenEx.writeCmds(newState, cmd.body)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.IfCond{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(#{stringifyAST(cmd.condition)}) -> (")
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Im.Gen.Helpers.writeLn(state, ")")
  end

  def stringifyAST(ast) do
    case ast do
      {:==, _pos, [left, right]} -> "#{stringifyAST(left)} == #{stringifyAST(right)}"
      {var, _pos, nil} -> var
      var when is_atom(var) -> var
      int when is_integer(int) -> int
    end
  end

end
