defmodule Im.Dsl.SubProcess do
  def process, do: %Spark.Dsl.Entity{
    name: :subprocess,
    describe: "A subprocess.",
    args: [:name, :arg],
    target: Im.SubProcess,
    schema: [
      name: [
        type: :string,
        doc: "Name of the subprocess"
      ],
      arg: [
        type: {:list, :atom},
        doc: "Argument list",
      ]
    ],
    entities: [run: [
      Im.Dsl.Entities.IfCondCmd.cmd,
      Im.Dsl.Entities.ReceiveCmd.cmd,
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.ChoiceCmd.cmd,
      Im.Dsl.Entities.CallCmd.cmd
    ]],
  }

end
