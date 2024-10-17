defmodule Im.Commands.Choice do
  defstruct [:label, :body]


  def writeMcrl2(%Im.Commands.Choice{} = cmd, %Im.Gen.GenState{} = state) do

    writeBody(%{state | indentation: state.indentation+1}, cmd.body)

  end

  def writeBody(state, [cmd | []]) do
    Im.Commands.writeMcrl2(cmd, state)
  end
  def writeBody(state, [cmd | cmds]) do
    Im.Commands.writeMcrl2(cmd, state)
    Im.Gen.Helpers.writeLn(state, "+")
    writeBody(state, cmds)
  end

end
