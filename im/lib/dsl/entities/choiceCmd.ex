defmodule Dsl.Entities.ChoiceCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :choice!,
    describe: "Non deterministic choice.",
    target: Commands.Choice,
    args: [:label],
    schema: [
      label: [
        type: :string
      ],
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.Mcrl2StateCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
    ]]
  }

end
