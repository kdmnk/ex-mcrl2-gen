defmodule Commands.IfThen do
  defstruct [:body]


  def writeEx(%Gen.GenState{} = state, %Commands.IfThen{} = cmd) do
    Gen.GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.IfThen{} = cmd) do
    Gen.GenMcrl2.writeCmds(state, cmd.body)
  end

end
