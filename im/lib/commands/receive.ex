defmodule Im.Commands.Receive do
  defstruct [:value, :from, :body]

  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd) do
    {newState, newCmd} = boundNewVariables(state, cmd)

    Enum.map(cmd.body, fn c ->
      Im.Commands.ReceiveCase.writeEx(newState, c, newCmd)
    end)
  end


  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd) do
    {newState, newCmd} = boundNewVariables(state, cmd)

    boundFrom = if newCmd.from not in state.bounded_vars do
        "sum #{newCmd.from} : Pid . "
    else
      ""
    end

    boundValue = if newCmd.value not in state.bounded_vars do
      "sum #{newCmd.value} : MessageType . "
    else
      ""
    end
    Im.Gen.Helpers.writeLn(newState, "(#{boundFrom}#{boundValue}(")

    caseString = fn (condition) ->
      Im.Gen.Helpers.writeLn(Im.Gen.GenState.indent(state), buildCmdString(newCmd, condition))
    end

    Im.Gen.Helpers.join(
      Im.Gen.GenState.indent(newState),
      fn (caseCmd) ->
        caseString.(Im.Gen.GenMcrl2.stringifyAST(caseCmd.condition))
        Im.Gen.GenMcrl2.writeCmds(Im.Gen.GenState.indent(state, 2), caseCmd.body)
      end,
      cmd.body,
      ") +"
    )
    Im.Gen.Helpers.writeLn(Im.Gen.GenState.indent(newState), ")")
    Im.Gen.Helpers.writeLn(newState, "))")
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

  def buildCmdString(%Im.Commands.Receive{} = cmd, condition) do
    "(#{condition}) -> (receiveMessage(pid, #{cmd.from}, #{cmd.value}) . "
  end

end
