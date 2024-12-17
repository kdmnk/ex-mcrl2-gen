defmodule Commands.Recurse do
  defstruct []

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Recurse{}) do
    args = Keyword.keys(state.var_state)

    Gen.Helpers.writeLn(state, "#{state.module_name}(#{Enum.join(args, ", ")})")
  end

  def writeEx(%Gen.GenState{}, %Commands.Recurse{}) do
    ""
  end

end
