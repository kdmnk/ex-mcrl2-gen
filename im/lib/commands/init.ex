defmodule Commands.Init do
  defstruct [:body]

  def writeEx(%Gen.GenState{} = state, %Commands.Init{} = cmd) do
    res = Gen.GenEx.writeCmds(state, cmd.body)
    IO.inspect(res)
    res
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Init{} = cmd) do
  end
end
