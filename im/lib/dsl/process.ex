defmodule Im.Dsl.Process do
  def process, do: %Spark.Dsl.Entity{
    name: :process,
    describe: "A process that defines commands.",
    args: [:identifier, :state],
    target: Im.Process,
    schema: [
      identifier: [
        type: :atom
      ],
      state: [
        type: {:map, :atom, {:tuple, [:atom, :atom]}},
        doc: "State of the process, defined as a map."
      ]
    ],
    entities: [run: [
      Im.Dsl.Entities.ReceiveCmd.cmd,
      Im.Dsl.Entities.SendCommand.cmd,
      Im.Dsl.Entities.ChoiceCmd.cmd
    ]]
  }
end
