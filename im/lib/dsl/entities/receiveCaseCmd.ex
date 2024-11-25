defmodule Im.Dsl.Entities.ReceiveCaseCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :when!,
    describe: "Receive case command.",
    target: Im.Commands.ReceiveCase,
    args: [:condition],
    schema: [
      condition: [
        type: :quoted,
      ]
    ],
    entities: [body: [
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.ChoiceCmd.cmd,
      Im.Dsl.Entities.StateCmd.cmd,
      Im.Dsl.Entities.CallCmd.cmd,
    ]]
  }
end
