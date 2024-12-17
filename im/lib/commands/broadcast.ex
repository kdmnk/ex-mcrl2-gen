defmodule Commands.Broadcast do
  defstruct [:to, :message]


  def writeEx(%Gen.GenState{} = state, %Commands.Broadcast{} = cmd) do
    """
    #{Gen.GenEx.writeLog(state, "broadcasting \#{inspect(#{cmd.message})} to #{cmd.to}")}
    var(state, :#{cmd.to})
    |> Enum.map(fn c -> GenServer.cast(c, {{__MODULE__, Node.self()}, #{cmd.message}}) end)
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Broadcast{} = cmd) do
    Gen.Helpers.writeLn(state, "broadcastMessages(pid, #{cmd.to}, #{cmd.message})")
  end

end
