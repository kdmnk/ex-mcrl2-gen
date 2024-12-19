defmodule Commands.State do
  defstruct [:value, :args, :body]

  def writeEx(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    state = %{state | current_state: cmd.value}
    Gen.GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    state = %Gen.GenState{state | current_state: cmd.value}
    args = case cmd.args do
      nil -> []
      x -> Keyword.new(x)
    end
    Gen.Helpers.writeLn(state, "#{state.module_name}#{cmd.value}(#{Gen.Helpers.getState(Keyword.merge(state.mcrl2_static_state, args))}) = ")

    Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.body, "+")
  end
end
