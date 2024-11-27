defmodule Dsl.Entities.SendCommand do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :send!,
    describe: "Send command.",
    target: Commands.Send,
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
