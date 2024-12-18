defmodule Commands.IfElse do
  defstruct [:body]


  def writeEx(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    Gen.GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    Gen.GenMcrl2.writeCmds(state, cmd.body)
  end

end
