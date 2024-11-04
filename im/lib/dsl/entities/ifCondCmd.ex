defmodule Im.Dsl.Entities.IfCondCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :ifcond,
    describe: "If condition holds, continue to body.",
    target: Im.Commands.IfCond,
    args: [:condition],
    schema: [
      condition: [
        type: :quoted,
      ]
    ],
    entities: [body: [
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.ChoiceCmd.cmd,
      Im.Dsl.Entities.CallCmd.cmd
    ]]
  }

end
