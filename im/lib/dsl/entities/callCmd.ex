defmodule Dsl.Entities.CallCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :call!,
    describe: "Call a subprocess",
    target: Commands.Call,
    args: [:name, :arg],
    schema: [
      name: [
        type: :string,
        doc: "Name of the subprocess"
      ],
      arg: [
        type: :quoted,
        doc: "Argument list",
      ]
    ],
    entities: [],
  }
end
