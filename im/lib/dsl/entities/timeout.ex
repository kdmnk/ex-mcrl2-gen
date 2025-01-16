defmodule Dsl.Entities.Timeout do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :timeout,
    describe: "Timeout",
    target: Commands.Timeout,
    args: [],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.Mcrl2StateCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
      Dsl.Entities.IfCmd.cmd
    ]],
  }

end
