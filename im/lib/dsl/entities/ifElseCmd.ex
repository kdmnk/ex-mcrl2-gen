defmodule Dsl.Entities.IfElseCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :else!,
    describe: "If condition holds, continue to then! child entity, otherwise, continue with else! child entity.",
    target: Commands.IfElse,
    args: [],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
    ]]
  }

end
