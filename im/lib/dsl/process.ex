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
      Im.Dsl.Entities.ChoiceCmd.cmd,
      Im.Dsl.Entities.CallCmd.cmd,
      Im.Dsl.Entities.IfCmd.cmd
    ]],
    transform: {__MODULE__, :transform_run, []}
  }

  @spec transform_run(__MODULE__) :: {:ok, __MODULE__}
  def transform_run(entity) do
    id = String.replace_prefix(to_string(entity.identifier), "Elixir.", "")
    state = Enum.map(entity.state, fn
      {name, {:pid, pidName}} -> {name, {:pid, String.replace_prefix(to_string(pidName), "Elixir.", "")}}
      v -> v
    end)
    {:ok, %{entity | identifier: id, state: state}}
  end
end
