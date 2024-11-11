defmodule Im.SubProcess do

  defstruct [:name, :arg, :run]

  def writeMcrl2(%Im.SubProcess{} = p, state) do

    args = Im.Gen.Helpers.getState(p.arg)

    Im.Gen.Helpers.writeLn(state, "#{p.name}(#{args}) = ")

    Im.Gen.GenMcrl2.writeCmds(Im.Gen.GenState.indent(state), p.run)

    Im.Gen.Helpers.writeLn(state, ";")
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.SubProcess{} = p) do
    args = Im.Gen.Helpers.getState(p.arg)
    GenEx.writeBlock(state, "def #{p.name}(#{args}) do", fn s ->
      Enum.map(p.run, fn cmd ->
        Im.Commands.writeEx(s, cmd)
      end)
    end)
  end


  def stateList(%Im.Process{} = p), do: Keyword.keys(p.state)

  def stateStr(%Im.Process{} = p) do
    Keyword.keys(p.state) |> Enum.join(", ")
  end

  def statePidNamesStr(%Im.Process{} = p) do
    Keyword.values(p.state)
    |> Enum.map(fn {:pid, name} -> Im.Gen.Helpers.pidName(name) end)
    |> Enum.join(", ")
  end

end
