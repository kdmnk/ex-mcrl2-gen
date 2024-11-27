defmodule Commands.State do
  defstruct [:state]

  def writeMcrl2(%Gen.GenState{} = state, %Commands.State{} = cmd) do
    Gen.Helpers.writeLn(state, "#{cmd.state}")
  end

  def writeEx(%Gen.GenState{}, %Commands.State{}) do

  end

end
