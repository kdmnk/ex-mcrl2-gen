defmodule Dsl.Entities.Mcrl2StateCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :mcrl2!,
    describe: "TODO",
    target: Commands.Mcrl2State,
    args: [:state],
    schema: [
      state: [
        type: :atom,
        doc: "Name of the state"
      ],
    ],
    entities: [],
  }
end