defmodule Dsl.Entities.Mcrl2StateCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :label!,
    describe: "TODO",
    target: Commands.Mcrl2State,
    args: [:state, :args],
    schema: [
      state: [
        type: :atom,
        doc: "Name of the state"
      ],
      args: [
        type: {:list, :any},
        doc: "Arguments of the state"
      ]
    ],
    entities: [],
  }
end
