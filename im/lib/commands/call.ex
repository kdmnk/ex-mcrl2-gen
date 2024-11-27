defmodule Commands.Call do
  defstruct [:name, :arg]

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Call{} = cmd) do
    args = Keyword.keys(state.module_state) ++ Enum.map(cmd.arg, fn x -> Gen.GenMcrl2.stringifyAST(x) end)

    Gen.Helpers.writeLn(state, "#{cmd.name}(#{Enum.join(args, ", ")})")
  end

  def writeEx(%Gen.GenState{} = state, %Commands.Call{} = cmd) do
    argNames = state.subprocesses[cmd.name] || []
    argVals = Enum.map(cmd.arg, fn x -> Gen.GenEx.stringifyAST(x, true) end) || []
    args = Enum.zip(argNames, argVals) |> Enum.map(fn {x, y} -> ":#{x} => #{y}" end)
    Gen.Helpers.writeLn(state, "state = updateState(state, %{#{Enum.join(args, ", ")}})")
    Gen.Helpers.writeLn(state, "state = #{cmd.name}(state)")
  end

end
