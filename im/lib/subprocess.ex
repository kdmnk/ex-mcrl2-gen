defmodule Im.SubProcess do

  defstruct [:name, :arg, :run]

  def writeMcrl2(%Im.SubProcess{} = p, state) do

    args = Im.Gen.Helpers.getState(p.arg)

    Im.Gen.Helpers.writeLn(state, "#{p.name}(#{args}) = ")

    Im.Gen.GenMcrl2.writeCmds(Im.Gen.GenState.indent(state), p.run)

    Im.Gen.Helpers.writeLn(state, ";")
  end

  # def writeEx(%Im.Gen.GenState{} = state, %Im.Process{} = p) do
  #   GenEx.writeBlock(state, "defmodule #{p.identifier} do", fn s ->
  #     GenEx.writeBlock(s, "def start(#{Im.Process.stateStr(p)}) do", fn s ->
  #       Im.Gen.Helpers.writeLn(s, "spawn(fn -> loop(#{Im.Process.stateStr(p)}) end)")
  #     end)
  #     GenEx.writeBlock(s, "defp loop(#{Im.Process.stateStr(p)}) do", fn s ->
  #       newState = %{s |
  #         bounded_vars: s.bounded_vars ++ Im.Process.stateList(p),
  #         module_name: p.identifier,
  #         module_state: Im.Process.stateList(p)}
  #       Enum.map(p.run, fn cmd ->
  #         Im.Commands.writeEx(newState, cmd)
  #       end)
  #       Im.Gen.Helpers.writeLn(newState, "loop(#{Im.Process.stateStr(p)})")
  #     end)
  #   end)
  # end


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
