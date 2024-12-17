defmodule Commands.Mcrl2State do
  defstruct [:state]

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Mcrl2State{} = cmd) do
    Gen.Helpers.writeLn(state, "#{cmd.state}")
  end

  def writeEx(%Gen.GenState{} = state, %Commands.Mcrl2State{} = cmd) do
    Gen.GenEx.writeLog(state, "state: #{cmd.state}")
  end

end
