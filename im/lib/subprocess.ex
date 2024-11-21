defmodule Im.SubProcess do

  defstruct [:process, :name, :arg, :run]

  def writeMcrl2(%Im.SubProcess{} = p, %Im.Gen.GenState{} = state) do

    args = Im.Gen.Helpers.getState(Keyword.merge(state.module_state, p.arg))

    Im.Gen.Helpers.writeLn(state, "#{p.name}(#{args}) = ")

    Im.Gen.GenMcrl2.writeCmds(Im.Gen.GenState.indent(state), p.run)

    Im.Gen.Helpers.writeLn(state, ";")
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.SubProcess{} = p) do
    GenEx.writeBlock(state, "def #{p.name}(state) do", fn s ->
      GenEx.writeCmds(s, p.run)
      Im.Gen.Helpers.writeLn(s, "state")
    end)
  end


  def stateList(%Im.SubProcess{} = p), do: Keyword.keys(p.arg)

  def stateStr(%Im.SubProcess{} = p) do
    stateList(p) |> Enum.join(", ")
  end

  def statePidNamesStr(%Im.SubProcess{} = p) do
    Keyword.values(p.arg)
    |> Enum.map(fn {:pid, name} -> Im.Gen.Helpers.pidName(name) end)
    |> Enum.join(", ")
  end

end
