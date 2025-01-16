defmodule Commands.Send do
  @behaviour Gen.GenBehaviour

  defstruct [:to, :message]


  def writeEx(%Gen.GenState{} = state, %Commands.Send{} = cmd) do
    to = Gen.GenEx.stringifyASTwithLookup(cmd.to)
    message = Gen.GenEx.stringifyASTwithLookup(cmd.message)
    """
    #{Gen.GenEx.writeLog(state, "sending \#{inspect(Message.new#{message})} to \#{inspect(#{to})}")}
    GenServer.cast(#{to}, {{__MODULE__, Node.self()}, Message.new#{message}})
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Send{} = cmd) do
    Gen.Helpers.writeLn(state, "sendMessage(pid, #{Gen.GenMcrl2.stringifyAST(cmd.to)}, MakeMessage(#{Gen.GenMcrl2.stringifyAST(cmd.message)}))")
  end

end
