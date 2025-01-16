defmodule Dsl.Entities.SendCommand do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :send!,
    describe: "Send command.",
    target: Commands.Send,
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
