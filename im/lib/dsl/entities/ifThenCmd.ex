defmodule Im.Dsl.Entities.IfThenCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :then!,
    describe: "",
    target: Im.Commands.IfThen,
    args: [],
    schema: [
    ],
    entities: [body: [
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.ChoiceCmd.cmd,
      Im.Dsl.Entities.CallCmd.cmd
    ]]
  }

end
