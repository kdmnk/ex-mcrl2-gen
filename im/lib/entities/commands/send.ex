defmodule Commands.Send do
  @behaviour Gen.GenBehaviour

  defstruct [:to, :message]


  def writeEx(%Gen.GenState{} = state, %Commands.Send{} = cmd) do
    to = Gen.GenEx.stringifyASTwithLookup(cmd.to)
    message = Gen.GenEx.stringifyASTwithLookup(cmd.message)
    message = if(state.struct_message_type, do: "Message.new#{message}", else: message)
    """
    #{Gen.GenEx.writeLog(state, "sending \#{inspect(#{message})} to \#{inspect(#{to})}")}
    GenServer.cast(#{to}, {{__MODULE__, Node.self()}, #{message}})
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Send{} = cmd) do
    Gen.Helpers.writeLn(state, "sendMessage(pid, #{Gen.GenMcrl2.stringifyAST(cmd.to)}, MakeMessage(#{Gen.GenMcrl2.stringifyAST(cmd.message)}))")
  end

end
