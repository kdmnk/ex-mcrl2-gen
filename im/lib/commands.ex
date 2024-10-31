defmodule Im.Commands do
  def writeMcrl2(%Im.Gen.GenState{} = state, cmd) do
    %module{} = cmd
    module.writeMcrl2(state, cmd)
  end

  def writeEx(%Im.Gen.GenState{} = state, cmd) do
    %module{} = cmd
    module.writeEx(state, cmd)
  end

end
