defmodule Dsl.Entities.SetCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :set!,
    describe: "Update the state",
    target: Commands.Set,
    args: [:key, :value],
    schema: [
      key: [
        type: :atom,
      ],
      value: [
        type: :quoted,
      ]
    ]
  }
end
