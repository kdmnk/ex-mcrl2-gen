defmodule Dsl.Entities.IfElseCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :else!,
    describe: "",
    target: Commands.IfElse,
    args: [],
    schema: [
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.CallCmd.cmd,
      Dsl.Entities.CallRecurseCmd.cmd,
      Dsl.Entities.StateCmd.cmd
    ]]
  }

end
