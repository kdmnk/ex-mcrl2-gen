defmodule Dsl.Entities.IfCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :if!,
    describe: "If condition holds, continue to then! child entity, otherwise, continue with else! child entity.",
    target: Commands.If,
    args: [:condition],
    schema: [
      condition: [
        type: :quoted,
      ]
    ],
    entities: [
      then: [Dsl.Entities.IfThenCmd.cmd],
      else: [Dsl.Entities.IfElseCmd.cmd],
    ]
  }

end
