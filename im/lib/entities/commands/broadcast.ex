defmodule Commands.Broadcast do
  @behaviour Gen.GenBehaviour

  defstruct [:to, :message]

  def writeEx(%Gen.GenState{} = state, %Commands.Broadcast{} = cmd) do
    """
    #{Gen.GenEx.writeLog(state, "broadcasting \#{inspect(Message.new#{Gen.GenEx.stringifyASTwithLookup(cmd.message)})} to #{Gen.GenEx.stringifyASTwithLookup(cmd.to)}")}
    #{Gen.GenEx.stringifyASTwithLookup(cmd.to)}
    |> Enum.map(fn c -> GenServer.cast(c, {{__MODULE__, Node.self()}, Message.new#{Gen.GenEx.stringifyASTwithLookup(cmd.message)}}) end)
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Broadcast{} = cmd) do
    Gen.Helpers.writeLn(state, "broadcastMessages(pid, #{Gen.GenMcrl2.stringifyAST(cmd.to)}, MakeMessage(#{Gen.GenMcrl2.stringifyAST(cmd.message)}))")
  end

end
