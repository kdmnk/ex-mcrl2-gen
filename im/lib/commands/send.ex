defmodule Im.Commands.Send do
  defstruct [:to, :message]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Send{} = cmd) do
    GenEx.writeLog(state, "sending \#{inspect(#{cmd.message})} to \#{inspect(Map.get(state.vars, :#{cmd.to}))}")
    Im.Gen.Helpers.writeLn(state, "send(Map.get(state.vars, :#{cmd.to}), {self(), #{cmd.message}})")
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Send{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "sendMessage(pid, #{cmd.to}, #{cmd.message})")
  end

end
