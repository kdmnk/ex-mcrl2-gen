defmodule Commands.State do
  defstruct [:value, :args, :body]

  def writeEx(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
    state = %{state | current_state: cmd.value}
    Gen.GenEx.writeCmds(state, cmd.body)
  end

  def writeMcrl2(%Gen.GenState{} = state, %__MODULE__{} = cmd) do
  end
end
