defmodule Dsl.Entities.StateCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :state!,
    describe: "TODO",
    target: Commands.State,
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
