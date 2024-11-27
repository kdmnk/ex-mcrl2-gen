defmodule Commands.Choice do
  defstruct [:label, :body]


  def writeEx(%Gen.GenState{} = state, %Commands.Choice{} = cmd) do
    Gen.Helpers.writeLn(state, "GenServer.cast(#{state.module_name}Api, {:new_choice, %#{state.module_name}Api.Choice#{getStateLabel(cmd)}State{choice: :#{cmd.label}, vars: state}})")
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Choice{} = cmd) do
    Gen.Helpers.writeLn(state, "(tau .", 1)
    Gen.GenMcrl2.writeCmds(%{state | indentation: state.indentation+1}, cmd.body, "+ tau .")
    Gen.Helpers.writeLn(state, ")", 1)
  end

  def getState(state) do
    "{"<>Enum.join(state, ", ")<>"}"
  end

  def getStateLabel(%Commands.Choice{label: label}) do
    "#{String.upcase(String.at(label, 0))}#{String.slice(label, 1..-1//1)}"
  end

end
