defmodule Commands.Choice do
  defstruct [:label, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.Choice{} = cmd) do
    """
    GenServer.cast({#{state.module_name}Api, Node.self()}, {:new_choice, %#{state.module_name}Api.Choice#{getStateLabel(cmd)}State{choice: :#{cmd.label}, vars: state}})
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Choice{} = cmd) do
    Gen.Helpers.writeLn(state, "(")
    Gen.Helpers.join(fn cmd ->
        Gen.Helpers.writeLn(state, "(tau .", 1)
        Commands.Command.writeMcrl2(Gen.GenState.indent(state, 2), cmd)
        Gen.Helpers.writeLn(state, ")", 1)
      end,
      cmd.body,
      fn -> Gen.Helpers.writeLn(state, "+") end)
    Gen.Helpers.writeLn(state, ")")
  end

  def getState(state) do
    "{"<>Enum.join(state, ", ")<>"}"
  end

  def getStateLabel(%Commands.Choice{label: label}) do
    "#{String.upcase(String.at(label, 0))}#{String.slice(label, 1..-1//1)}"
  end

end
