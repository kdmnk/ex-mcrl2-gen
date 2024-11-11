defmodule Im.Commands.Choice do
  defstruct [:label, :body]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Choice{} = cmd) do
    Im.Gen.Helpers.addNonDeterministicChoice(cmd.label)
    GenEx.writeBlock(state, "if Main.#{cmd.label}(__MODULE__, #{getState(state.module_state)}) do", fn s ->
      GenEx.writeCmds(s, [Enum.at(cmd.body, 0)])
      Im.Gen.Helpers.writeLn(s, "else", -1)
      GenEx.writeCmds(s, [Enum.at(cmd.body, 1)])
    end)
  end

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Choice{} = cmd) do
    Im.Gen.Helpers.writeLn(state, "(tau .", 1)
    Im.Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body, "+ tau .")
    Im.Gen.Helpers.writeLn(state, ")", 1)
  end


  def getState(state) do
    "{"<>Enum.join(state, ", ")<>"}"
  end

end
