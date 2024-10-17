defmodule Im.Commands.IfCond do
  defstruct [:condition, :body]


  def writeMcrl2(%Im.Commands.IfCond{} = cmd, %Im.Gen.GenState{} = state) do
    Im.Gen.Helpers.writeLn(state, "(#{stringifyAST(cmd.condition)}) -> (")

    Enum.map(cmd.body, fn (cmd) ->
      Im.Commands.writeMcrl2(cmd, %{state | indentation: state.indentation+1})
    end)
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
