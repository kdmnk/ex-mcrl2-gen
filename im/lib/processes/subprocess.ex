# defmodule Processes.SubProcess do

#   defstruct [:process, :name, :arg, :run]

#   def writeMcrl2(%__MODULE__{} = p, %Gen.GenState{} = state) do

#     args = Gen.Helpers.getState(Keyword.merge(state.mcrl2_static_state, p.arg))

#     Gen.Helpers.writeLn(state, "#{p.name}(#{args}) = ")

#     Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), p.run)

#     Gen.Helpers.writeLn(state, ";")
#   end

#   def writeEx(%Gen.GenState{} = state, %__MODULE__{} = p) do
#     Gen.GenEx.writeBlock(state, "def #{p.name}(state) do", fn s ->
#       Gen.GenEx.writeCmds(s, p.run)
#       Gen.Helpers.writeLn(s, "state")
#     end)
#   end


#   def stateList(%__MODULE__{} = p), do: Keyword.keys(p.arg)

#   def stateStr(%__MODULE__{} = p) do
#     stateList(p) |> Enum.join(", ")
#   end

#   def statePidNamesStr(%__MODULE__{} = p) do
#     Keyword.values(p.arg)
#     |> Enum.map(fn {:pid, name} -> Gen.Helpers.pidName(name) end)
#     |> Enum.join(", ")
#   end

# end
