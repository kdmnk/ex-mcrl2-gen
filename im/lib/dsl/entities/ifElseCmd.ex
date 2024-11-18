defmodule Im.Dsl.Entities.IfElseCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :else!,
    describe: "",
    target: Im.Commands.IfElse,
    args: [],
    schema: [
    ],
    entities: [body: [
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.ChoiceCmd.cmd,
      Im.Dsl.Entities.CallCmd.cmd
    ]]
  }

end
