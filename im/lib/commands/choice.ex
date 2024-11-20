defmodule Im.Commands.Choice do
  defstruct [:label, :body]


  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Choice{} = cmd) do
    Im.Gen.Helpers.addNonDeterministicChoice(cmd)

    vars = Enum.map(state.bounded_vars, fn var -> ":#{var} => #{var}" end)
    Im.Gen.Helpers.writeLn(state, "state = %{#{Enum.join(vars, ", ")}}")
    Im.Gen.Helpers.writeLn(state, "GenServer.cast(#{state.module_name}Api, %#{state.module_name}Api.Choice#{cmd.label}State{choice: :#{cmd.label}, vars: state})")
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
