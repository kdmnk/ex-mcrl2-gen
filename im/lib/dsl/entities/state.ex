defmodule Dsl.Entities.State do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :state,
    describe: "Define a state",
    target: Commands.State,
    args: [:value, :args],
    schema: [
      value: [
        type: :atom,
        doc: "State name",
      ],
      args: [
        type: {:map, :atom, {:or, [
          {:tuple, [:atom, :atom]},
          :atom
          ]}}
      ]
    ],
    entities: [body: [
      Dsl.Entities.ReceiveCmd.cmd
    ]],
  }

end