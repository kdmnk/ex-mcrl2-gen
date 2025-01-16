defmodule Dsl.Entities.BroadcastCmd do
  def cmd(), do: %Spark.Dsl.Entity{
    name: :broadcast!,
    describe: "Broadcast command.",
    target: Commands.Broadcast,
    args: [:to, :message],
    schema: [
      to: [
        type: :quoted
      ],
      message: [
        type: :quoted
      ]
    ],
  }
end
