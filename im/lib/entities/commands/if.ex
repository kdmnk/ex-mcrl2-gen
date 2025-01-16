defmodule Commands.If do
  @behaviour Gen.GenBehaviour

  defstruct [:condition, :then, :else]


  def writeEx(%Gen.GenState{} = state, %Commands.If{} = cmd) do
    """
    state = if (#{Gen.GenEx.stringifyASTwithLookup(cmd.condition)}) do
      #{Gen.GenEx.writeCmds(state, cmd.then)}
      state
    else
      #{Gen.GenEx.writeCmds(state, cmd.else)}
      state
    end
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.If{} = cmd) do
    case cmd.else do
      [] ->
        Gen.Helpers.writeLn(state, "((#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
        Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.then)
        Gen.Helpers.writeLn(state, "))")
      _ ->
        Gen.Helpers.writeLn(state, "((#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
        Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.then)
        Gen.Helpers.writeLn(state, ") <> (")
        Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.else)
        Gen.Helpers.writeLn(state, "))")
    end
  end

end
