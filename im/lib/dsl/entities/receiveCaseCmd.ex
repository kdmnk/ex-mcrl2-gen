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
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.Mcrl2StateCmd.cmd,
      Dsl.Entities.CallRecurseCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
      Dsl.Entities.SetCmd.cmd,
      Dsl.Entities.IfCmd.cmd,
    ]]
  }
end
