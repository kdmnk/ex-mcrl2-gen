defmodule Dsl.Entities.IfThenCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :then!,
    describe: "",
    target: Commands.IfThen,
    args: [],
    schema: [
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.CallCmd.cmd,
      Dsl.Entities.CallRecurseCmd.cmd,
      Dsl.Entities.StateCmd.cmd
    ]]
  }

end
