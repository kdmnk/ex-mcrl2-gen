defmodule Commands.Receive do
  alias Commands.ReceiveCase
  defstruct [:value, :from, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
    newCmd = genVarNames(cmd)

    Enum.map(cmd.body, fn c ->
      Commands.ReceiveCase.writeEx(state, c, newCmd)
    end)
    |> Enum.join("\n")
  end


  def writeMcrl2(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
    newCmd = genVarNames(cmd)

    Gen.Helpers.writeLn(state, "(sum #{newCmd.from} : Pid . sum #{newCmd.value} : MessageType . (")

    caseString = fn (condition) ->
      Gen.Helpers.writeLn(Gen.GenState.indent(state), buildCmdString(newCmd, condition))
    end

    Gen.Helpers.join(
      fn (%ReceiveCase{} = caseCmd) ->
        caseString.(Gen.GenMcrl2.stringifyAST(caseCmd.condition))
        Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state, 2), caseCmd.body)
      end,
      cmd.body,
      fn -> Gen.Helpers.writeLn(Gen.GenState.indent(state), ") +") end
    )
    Gen.Helpers.writeLn(Gen.GenState.indent(state), ")")
    Gen.Helpers.writeLn(state, "))")
  end

  def genVarNames(%Commands.Receive{} = cmd) do
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

    %{cmd | value: value, from: from}
  end

  def buildCmdString(%Commands.Receive{} = cmd, condition) do
    "(#{condition}) -> (receiveMessage(pid, #{cmd.from}, #{cmd.value}) . "
  end

end
