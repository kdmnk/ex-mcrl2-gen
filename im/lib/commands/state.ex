defmodule Im.Commands.State do
  defstruct [:state]

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.State{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "#{cmd.state}")
  end

  def writeEx(%Im.Gen.GenState{}, %Im.Commands.State{}) do

  end

end
