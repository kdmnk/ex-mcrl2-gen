defmodule Im.Process do
  defstruct [:identifier, :state, :run]

  def writeMcrl2(%Im.Process{} = p, state) do
    Im.Gen.Helpers.writeLn(state, "#{p.identifier}(#{Im.Gen.Helpers.getState(p.state)}) = ")

    writeBody(%{state | indentation: state.indentation+1, bounded_vars: ["pid" | Map.keys(p.state)]}, p.run)

    Im.Gen.Helpers.writeLn(%{state | indentation: state.indentation+1}, "#{p.identifier}();")
  end

  def writeBody(state, [cmd | []]) do
    Im.Commands.writeMcrl2(cmd, state)
  end
  def writeBody(state, [cmd | cmds]) do
    Im.Commands.writeMcrl2(cmd, state)
    Im.Gen.Helpers.writeLn(state, ".")
    writeBody(state, cmds)
  end

end
