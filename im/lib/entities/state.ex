defmodule Entities.State do
  @behaviour Gen.GenBehaviour

  defstruct [:value, :args, :body, :timeout]

  def writeEx(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    state = %Gen.GenState{state | current_state: cmd.value}
    body = Gen.GenEx.writeCmds(state, cmd.body)

    timeout = if cmd.timeout != nil && cmd.timeout != [] do
      Gen.GenEx.writeCmds(state, cmd.timeout)
    else
      ""
    end
    """
    #{body}
    #{timeout}
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    state = %Gen.GenState{state | current_state: cmd.value}
    args = case cmd.args do
      nil -> []
      x -> Keyword.new(x)
    end
    Gen.Helpers.writeLn(state, "#{state.module_name}#{cmd.value}(#{Gen.Helpers.getState(Keyword.merge(state.mcrl2_static_state, args))}) = ")

    Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.body, "+")
    if cmd.timeout != nil && cmd.timeout != [] do
      Gen.Helpers.writeLn(Gen.GenState.indent(state), "+ timeout(pid) . ")
      Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.timeout, "+")
    end

    crashed_args = Keyword.keys(state.mcrl2_static_state) ++ Keyword.keys(args)
    |> Enum.join(", ")

    Gen.Helpers.writeLn(Gen.GenState.indent(state), "+ (ALLOW_CRASH) -> crash(pid) . #{state.module_name}#{cmd.value}crashed(#{crashed_args});\n")

    Gen.Helpers.writeLn(Gen.GenState.indent(state), "#{state.module_name}#{cmd.value}crashed(#{Gen.Helpers.getState(Keyword.merge(state.mcrl2_static_state, args))}) = ")
    Gen.Helpers.writeLn(Gen.GenState.indent(state, 2), "(sum server : Pid . sum m : MessageData . receiveMessage(pid, server, m)) . #{state.module_name}#{cmd.value}crashed(#{crashed_args})")
    Gen.Helpers.writeLn(Gen.GenState.indent(state, 2), "+ resume(pid) . #{state.module_name}#{cmd.value}(#{crashed_args})")
  end
end
