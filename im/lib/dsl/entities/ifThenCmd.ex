defmodule Dsl.Entities.IfThenCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :then!,
    describe: "If condition holds, continue to then! child entity, otherwise, continue with else! child entity.",
    target: Commands.IfThen,
    args: [],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
    ]]
  }

end
