defmodule Commands.ReceiveCase do
  defstruct [:condition, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.ReceiveCase{} = cmd, %Commands.Receive{} = receiveCmd) do
    """
    def handle_cast({#{receiveCmd.from}, #{receiveCmd.value}}, state) when state.state == :#{state.current_state} and (#{
      Gen.GenEx.stringifyAST(cmd.condition,
        fn
          x when x == receiveCmd.from -> x
          x when x == receiveCmd.value -> x
          x -> "state.#{x}"
        end)}) do
      #{Gen.GenEx.writeLog(state, "received \#{inspect(#{receiveCmd.value})} from \#{inspect(#{receiveCmd.from})}" <> " (#{Gen.GenEx.stringifyAST(cmd.condition)})")}
      state = updateState(state, %{:#{receiveCmd.value} => #{receiveCmd.value}, :#{receiveCmd.from} => #{receiveCmd.from}})
      #{Gen.GenEx.writeCmds(state, cmd.body)}
      {:noreply, state}
    end
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.ReceiveCase{} = cmd) do
    Gen.Helpers.writeLn(state, "(#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.body)
    Gen.Helpers.writeLn(state, ")")
  end

end
