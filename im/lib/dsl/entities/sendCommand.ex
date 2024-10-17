defmodule Im.Dsl.Entities.SendCommand do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :snd,
    describe: "Send command.",
    target: Im.Commands.Send,
    args: [:to, :message],
    schema: [
      to: [
        type: {:or, [:atom, :string]}
      ],
      message: [
        type: Im.Dsl.Im.messageType()
      ]
    ],
  }
end
