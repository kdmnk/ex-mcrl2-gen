defmodule Commands.Receive do
  defstruct [:value, :from, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
    {newState, newCmd} = boundNewVariables(state, cmd)

    Enum.map(cmd.body, fn c ->
      Commands.ReceiveCase.writeEx(newState, c, newCmd)
    end)
    |> Enum.join("\n")
  end


  def writeMcrl2(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
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
    Gen.Helpers.writeLn(newState, "(#{boundFrom}#{boundValue}(")

    caseString = fn (condition) ->
      Gen.Helpers.writeLn(Gen.GenState.indent(state), buildCmdString(newCmd, condition))
    end

    Gen.Helpers.join(
      Gen.GenState.indent(newState),
      fn (caseCmd) ->
        caseString.(Gen.GenMcrl2.stringifyAST(caseCmd.condition))
        Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state, 2), caseCmd.body)
      end,
      cmd.body,
      ") +"
    )
    Gen.Helpers.writeLn(Gen.GenState.indent(newState), ")")
    Gen.Helpers.writeLn(newState, "))")
  end

  def boundNewVariables(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
    value = if cmd.value == nil do
      "val#{Gen.Helpers.getNextId()}"
    else
      cmd.value
    end

    from = if cmd.from == nil do
      "pid#{Gen.Helpers.getNextId()}"
    else
      cmd.from
    end

    {%{state | bounded_vars: [value | [from | state.bounded_vars]]}, %{cmd | value: value, from: from}}
  end

  def buildCmdString(%Commands.Receive{} = cmd, condition) do
    "(#{condition}) -> (receiveMessage(pid, #{cmd.from}, #{cmd.value}) . "
  end

end
