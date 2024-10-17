defmodule Im.Commands do
  def writeMcrl2(cmd, %Im.Gen.GenState{} = state) do
    %module{} = cmd
    module.writeMcrl2(cmd, state)
  end
end
