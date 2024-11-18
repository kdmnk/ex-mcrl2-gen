defmodule Im.Dsl.Entities.IfCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :if!,
    describe: "If condition holds, continue to then! child entity, otherwise, continue with else! child entity.",
    target: Im.Commands.If,
    args: [:condition],
    schema: [
      condition: [
        type: :quoted,
      ]
    ],
    entities: [else: [
      Im.Dsl.Entities.IfElseCmd.cmd,
    ], then: [
      Im.Dsl.Entities.IfThenCmd.cmd,
    ]]
  }

end
