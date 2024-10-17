defmodule Im.Commands.Send do
  defstruct [:to, :message]

  def writeMcrl2(%Im.Commands.Send{:to => to, :message => message}, %Im.Gen.GenState{} = state) do
    Im.Gen.Helpers.writeLn(state, "sendMessage(pid, #{to}, #{message})")
  end

end
