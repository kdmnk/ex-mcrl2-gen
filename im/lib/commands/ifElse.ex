defmodule Im.Commands.IfElse do
  defstruct [:body]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.IfElse{} = cmd) do
    GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.IfElse{} = cmd) do
    Im.Gen.GenMcrl2.writeCmds(state, cmd.body)
  end

end
