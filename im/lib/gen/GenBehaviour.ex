defmodule Gen.GenBehaviour do
  @callback writeEx(state :: %Gen.GenState{}, cmd :: term()) :: String.t()
  @callback writeMcrl2(state :: %Gen.GenState{}, cmd :: term()) :: :ok
end
