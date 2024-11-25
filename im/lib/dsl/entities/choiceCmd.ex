defmodule Im.Dsl.Entities.ChoiceCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :choice!,
    describe: "Non deterministic choice.",
    target: Im.Commands.Choice,
    args: [:label],
    schema: [
      label: [
        type: :string
      ],
    ],
    entities: [body: [
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.StateCmd.cmd
    ]]
  }

end
