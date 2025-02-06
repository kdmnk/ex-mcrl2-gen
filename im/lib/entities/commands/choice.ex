defmodule Commands.Choice do
  @behaviour Gen.GenBehaviour

  defstruct [:name, :values, :body]

  def writeEx(%Gen.GenState{} = state, %Commands.Choice{} = cmd) do
    """
    GenServer.cast({#{state.module_name}Api, Node.self()}, {:new_choice, %#{state.module_name}Api.Choice#{getStateLabel(cmd)}State{choice: :#{cmd.name}, vars: state}})
    """
  end

  def writeMcrl2(%Gen.GenState{} = state, %Commands.Choice{} = cmd) do
    criteria = fn (name) ->
      case cmd.values do
        %Range{first: from, last: to} -> "#{name} >= #{from} && #{name} <= #{to}"
        [l|ls] -> "#{name} in [#{Enum.join([l|ls], ", ")}]"
      end
    end
    values_type = case List.first(Enum.to_list(cmd.values)) do
      x when is_integer(x) -> "Nat"
      x when is_boolean(x) -> "Bool"
    end

    Gen.Helpers.writeLn(state, "(sum #{cmd.name} : #{values_type} . (#{criteria.(cmd.name)}) -> tau . (")
    Gen.GenMcrl2.writeCmds(Gen.GenState.indent(state), cmd.body)
    Gen.Helpers.writeLn(state, "))")
  end

  def getStateLabel(%Commands.Choice{name: name}) do
    "#{String.upcase(String.at("#{name}", 0))}#{String.slice("#{name}", 1..-1//1)}"
  end

end
