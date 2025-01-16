defmodule Commands.Timeout do
  @behaviour Gen.GenBehaviour

  defstruct [:body]

  def writeEx(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    """
    def handle_cast(:timeout, state) when state.state == :#{state.current_state} do
      #{Gen.GenEx.writeLog(state, "timeout")}
      state = updateState(state, %{})
      #{Gen.GenEx.writeCmds(state, cmd.body)}
      {:noreply, state}
    end
    """
    #"""

    # def choose#{Commands.Choice.getStateLabel(cmd)}(%Choice#{Commands.Choice.getStateLabel(cmd)}State{}, choice) do
    #   GenServer.cast({#{p.identifier}, Node.self()}, {:#{cmd.label}, choice})
    #   %IdleState{}
    # end
    # def handle_cast({#{newCmd.from}, #{newCmd.value}}, state) when state.state == :#{state.current_state} and (#{
    #   Gen.GenEx.stringifyAST(cmd.condition,
    #     fn
    #       x when x == newCmd.from -> x
    #       x when x == newCmd.value -> x
    #       x -> "state.#{x}"
    #     end)}) do
    #   #{Gen.GenEx.writeLog(state, "received \#{inspect(#{newCmd.value})} from \#{inspect(#{newCmd.from})}" <> " (#{Gen.GenEx.stringifyAST(cmd.condition)})")}
    #   state = updateState(state, %{:#{newCmd.value} => #{newCmd.value}, :#{newCmd.from} => #{newCmd.from}})
    #   #{Gen.GenEx.writeCmds(state, cmd.body)}
    #   {:noreply, state}
    # end
    #"""
  end

  def writeMcrl2(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    Gen.GenMcrl2.writeCmds(state, cmd.body)
  end

end
