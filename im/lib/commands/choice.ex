defmodule Im.Commands.Choice do
  defstruct [:label, :body]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Choice{} = cmd) do
    Im.Gen.Helpers.addNonDeterministicChoice(cmd)

    vars = Enum.map(state.bounded_vars, fn var -> ":#{var} => #{var}" end)
    Im.Gen.Helpers.writeLn(state, "state = %ChoiceState{choice: :#{cmd.label}, vars: %{#{Enum.join(vars, ", ")}}}")

    GenEx.writeBlock(state, "if waiting do", fn s ->
      Im.Gen.Helpers.writeLn(s, "GenServer.reply(waiting, state)")
    end)
    Im.Gen.Helpers.writeLn(state, "waiting = true")
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
