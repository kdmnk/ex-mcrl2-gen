defmodule Commands.Mcrl2State do
  @behaviour Gen.GenBehaviour

  defstruct [:state, :args]

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Mcrl2State{} = cmd) do
    if cmd.args == [] do
      Gen.Helpers.writeLn(state, "#{cmd.state}")
    else
      Gen.Helpers.writeLn(state, "#{cmd.state}#{Gen.GenMcrl2.stringifyAST(cmd.args)}")
    end
  end

  def writeEx(%Gen.GenState{} = state, %Commands.Mcrl2State{} = cmd) do
    Gen.GenEx.writeLog(state, "state: #{cmd.state}")
  end

end
