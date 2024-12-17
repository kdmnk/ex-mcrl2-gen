defmodule Commands.If do
  defstruct [:condition, :body]


  def writeEx(%Gen.GenState{} = state, %Commands.If{} = cmd) do
    """
    state = if (#{Gen.GenEx.stringifyASTwithLookup(cmd.condition)}) do
      #{Gen.GenEx.writeCmds(state, cmd.body)}
      state
    else
      state
    end
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.If{} = cmd) do
    Gen.Helpers.writeLn(state, "((#{Gen.GenMcrl2.stringifyAST(cmd.condition)}) -> (")
    Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body)
    Gen.Helpers.writeLn(state, ")")
  end

end
