defmodule Dsl.Entities.ChangeStateCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :state!,
    describe: "Change the state",
    target: Commands.ChangeState,
    args: [:value, :args],
    schema: [
      value: [
        type: :atom,
        doc: "State name",
      ],
      args: [
        type: :quoted,
        doc: "Arguments to pass to the state",
      ]
    ]
  }

end
