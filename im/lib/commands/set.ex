defmodule Commands.Set do
  defstruct [:key, :value]

  def writeEx(%Gen.GenState{} = state, %Commands.Set{} = cmd) do
    """
    state = updateState(state, %{:#{cmd.key} => #{Gen.GenEx.stringifyASTwithLookup(cmd.value)}})
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Set{} = cmd) do
  end
end
