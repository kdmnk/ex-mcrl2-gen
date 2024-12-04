defmodule Commands.Broadcast do
  defstruct [:to, :message]


  def writeEx(%Gen.GenState{} = state, %Commands.Broadcast{} = cmd) do
    Gen.GenEx.writeLog(state, "TODO broadcast")
    # Gen.GenEx.writeLog(state, "sending \#{inspect(#{cmd.message})} to \#{inspect(var(state, :#{cmd.to}))}")
    # Gen.Helpers.writeLn(state, "GenServer.cast(var(state, :#{cmd.to}), {self(), #{cmd.message}})")
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Broadcast{} = cmd) do
    Gen.Helpers.writeLn(state, "broadcastMessages(pid, #{cmd.to}, #{cmd.message})")
  end

end
