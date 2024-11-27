defmodule Dsl.Entities.ReceiveCaseCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :when!,
    describe: "Receive case command.",
    target: Commands.ReceiveCase,
    args: [:condition],
    schema: [
      condition: [
        type: :quoted,
      ]
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.StateCmd.cmd,
      Dsl.Entities.CallCmd.cmd,
      Dsl.Entities.CallRecurseCmd.cmd,
    ]]
  }
end
