defmodule Dsl.Entities.Init do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :init,
    describe: "Initial commands",
    target: Entities.Init,
    args: [],
    schema: [
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.IfCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
    ]],
  }

end
