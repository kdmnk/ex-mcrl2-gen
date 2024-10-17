defmodule Im.Commands.Receive do
  defstruct [:value, :from, :body]

  def writeMcrl2(%Im.Commands.Receive{} = cmd, %Im.Gen.GenState{} = state) do

    value = if cmd.value == nil do
      "val#{Im.Gen.Helpers.getNextId()}"
    else
      cmd.value
    end

    from = if cmd.from == nil do
      "pid#{Im.Gen.Helpers.getNextId()}"
    else
      cmd.from
    end

    Im.Gen.Helpers.writeLn(state, "(" <> buildCmdString(from, value, state.bounded_vars))

    # Body can only be IfCond
    writeBody(%{state |
      indentation: state.indentation+1,
      bounded_vars: [value | [from | state.bounded_vars]]
    }, cmd.body)

    Im.Gen.Helpers.writeLn(state, ") .")
  end

  def buildCmdString(from, value, bounded_vars) do
    cond do
      from not in bounded_vars ->
        "sum #{from} : Pid . " <> buildCmdString(from, value, [from | bounded_vars])
      value not in bounded_vars ->
        "sum #{value} : MessageType . " <> buildCmdString(from, value, [value | bounded_vars])
      true ->
        "receiveMessage(pid, #{value}, #{from}) ."
    end
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
