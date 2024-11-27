defmodule Commands.IfElse do
  defstruct [:body]


  def writeEx(%Gen.GenState{} = state, %Commands.IfElse{} = cmd) do
    Gen.GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.IfElse{} = cmd) do
    Gen.GenMcrl2.writeCmds(state, cmd.body)
  end

end
