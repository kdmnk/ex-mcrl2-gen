defmodule Commands.Receive do
  @behaviour Gen.GenBehaviour

  defstruct [:value, :from, :condition, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
    newCmd = genVarNames(cmd)
    """
    def handle_cast({#{newCmd.from}, #{newCmd.value}}, state) when state.state == :#{state.current_state} and (#{
      Gen.GenEx.stringifyAST(cmd.condition,
        fn
          x when x == newCmd.from -> x
          x when x == newCmd.value -> x
          x -> "state.#{x}"
        end)}) do
      #{Gen.GenEx.writeLog(state, "received \#{inspect(#{newCmd.value})} from \#{inspect(#{newCmd.from})}" <> " (#{Gen.GenEx.stringifyAST(cmd.condition)})")}
      state = updateState(state, %{:#{newCmd.value} => #{newCmd.value}, :#{newCmd.from} => #{newCmd.from}})
      #{Gen.GenEx.writeCmds(state, cmd.body)}
      {:noreply, state}
    end
    """
  end


  def writeMcrl2(%Gen.GenState{} = state, %Commands.Receive{} = cmd) do
    newCmd = genVarNames(cmd)

    Gen.Helpers.writeLn(state, "(sum #{newCmd.from} : Pid . sum #{newCmd.value} : MessageData . (")
    Gen.Helpers.writeLn(Gen.GenState.indent(state), "(#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (receiveMessage(pid, #{newCmd.from}, #{newCmd.value}) . ")
    Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state, 2), cmd.body)
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

end
