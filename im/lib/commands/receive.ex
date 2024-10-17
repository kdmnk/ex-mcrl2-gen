defmodule Im.Commands.Receive do
  defstruct [:value, :from, :body]

  def writeMcrl2(%Im.Commands.Receive{} = cmd, %Im.Gen.GenState{} = state) do
    Im.Gen.Helpers.writeLn(state, "(receiveMessage(pid, #{cmd.from}, #{cmd.value}) .")

    # Body can only be IfCond
    writeBody(%{state | indentation: state.indentation+1}, cmd.body)

    Im.Gen.Helpers.writeLn(state, ") .")
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
