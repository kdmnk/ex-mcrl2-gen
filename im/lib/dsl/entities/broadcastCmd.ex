defmodule Dsl.Entities.BroadcastCmd do
  def cmd(), do: %Spark.Dsl.Entity{
    name: :broadcast!,
    describe: "Broadcast command.",
    target: Commands.Broadcast,
    args: [:to, :message],
    schema: [
      to: [
        type: {:or, [:atom, :string]}
      ],
      message: [
        type: {:or, [:atom, :string, :integer]}
      ]
    ],
  }
end
