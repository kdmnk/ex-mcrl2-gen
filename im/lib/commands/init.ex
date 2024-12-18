defmodule Commands.Init do
  defstruct [:body]

  def writeEx(%Gen.GenState{} = state, %Commands.Init{} = cmd) do
    Gen.GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Init{} = cmd) do
    Gen.GenMcrl2.writeCmds(state, cmd.body)
  end
end
