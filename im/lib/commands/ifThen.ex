defmodule Im.Commands.IfThen do
  defstruct [:body]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.IfThen{} = cmd) do
    GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.IfThen{} = cmd) do
    Im.Gen.GenMcrl2.writeCmds(state, cmd.body)
  end

end
