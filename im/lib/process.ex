defmodule Im.Process do
  alias Im.Gen.GenMcrl2

  defstruct [:identifier, :state, :run]

  def writeMcrl2(%Im.Process{} = p, state) do
    Im.Gen.Helpers.writeLn(state, "#{p.identifier}(#{Im.Gen.Helpers.getState(p.state)}) = ")

    GenMcrl2.writeCmds(Im.Gen.GenState.indent(Im.Gen.GenState.addBoundVars(state, ["pid" | stateList(p)])), p.run)

    Im.Gen.Helpers.writeLn(state, ". #{p.identifier}();", +1)
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.Process{} = p) do
    GenEx.writeBlock(state, "defmodule #{p.identifier} do", fn s ->
      GenEx.writeBlock(s, "def start(#{Im.Process.stateStr(p)}) do", fn s ->
        Im.Gen.Helpers.writeLn(s, "spawn(fn -> loop(#{Im.Process.stateStr(p)}) end)")
      end)
      GenEx.writeBlock(s, "defp loop(#{Im.Process.stateStr(p)}) do", fn s ->
        newState = %{s |
          bounded_vars: s.bounded_vars ++ Im.Process.stateList(p),
          module_name: p.identifier,
          module_state: Im.Process.stateList(p)}
        Enum.map(p.run, fn cmd ->
          Im.Commands.writeEx(newState, cmd)
        end)
        Im.Gen.Helpers.writeLn(newState, "loop(#{Im.Process.stateStr(p)})")
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
