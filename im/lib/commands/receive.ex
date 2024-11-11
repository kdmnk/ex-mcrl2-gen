defmodule Im.Commands.Receive do
  defstruct [:value, :from, :body]

  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd) do
    {newState, newCmd} = boundNewVariables(state, cmd)

    Enum.map(cmd.body, fn c ->
      Im.Commands.IfCond.writeEx(newState, c, newCmd)
    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd) do
    {newState, newCmd} = boundNewVariables(state, cmd)

    caseString = fn (condition) ->
      Im.Gen.Helpers.writeLn(state, buildCmdString(state, newCmd, condition))
    end

    Im.Gen.Helpers.join(
      state,
      fn (caseCmd) ->
        caseString.(Im.Gen.GenMcrl2.stringifyAST(caseCmd.condition))
        Im.Gen.GenMcrl2.writeCmds(%{newState | indentation: state.indentation+1}, caseCmd.body)
      end,
      cmd.body,
      "+"
    )

  end

  def boundNewVariables(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd) do
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

    {%{state | bounded_vars: [value | [from | state.bounded_vars]]}, %{cmd | value: value, from: from}}
  end

  def buildCmdString(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd, condition) do
    boundFrom = if cmd.from not in state.bounded_vars do
        "sum #{cmd.from} : Pid . "
    else
      ""
    end

    boundValue = if cmd.value not in state.bounded_vars do
      "sum #{cmd.value} : MessageType . "
    else
      ""
    end

    "#{boundFrom}#{boundValue}(#{condition}) -> receiveMessage(pid, #{cmd.from}, #{cmd.value}) . "
  end

end
