defmodule Commands.Command do
  @behaviour Gen.GenBehaviour
  def writeMcrl2(%Gen.GenState{} = state, cmd) do
    %module{} = cmd
    module.writeMcrl2(state, cmd)
  end

  def writeEx(%Gen.GenState{} = state, cmd) do
    %module{} = cmd
    module.writeEx(state, cmd)
  end

end
