defmodule Commands.ChangeState do
  defstruct [:value, :args]

  def writeEx(%Gen.GenState{} = state, %Commands.ChangeState{} = cmd) do
    argNames = case Map.get(state.states_args, cmd.value) do
      nil -> []
      x -> Map.keys(x)
    end
    argVals = Enum.map(cmd.args, fn x -> Gen.GenEx.stringifyASTwithLookup(x) end)
    args = [":state => :#{cmd.value}" | Enum.zip(argNames, argVals) |> Enum.map(fn {x, y} -> ":#{x} => #{y}" end)]
    "state = updateState(state, %{#{Enum.join(args, ", ")}})"
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.ChangeState{} = cmd) do
  end
end
