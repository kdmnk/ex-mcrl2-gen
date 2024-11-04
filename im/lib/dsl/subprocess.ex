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
        type: {:map, :atom, {:or, [
          {:tuple, [:atom, :atom]},
          :atom
          ]}},
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
    transform: {__MODULE__, :transform_run, []}
  }

  @spec transform_run(__MODULE__) :: {:ok, __MODULE__}
  def transform_run(entity) do
    state = Enum.map(entity.arg, fn
      {name, {:pid, pidName}} -> {name, {:pid, String.replace_prefix(to_string(pidName), "Elixir.", "")}}
      v -> v
    end)
    {:ok, %{entity | arg: state}}
  end

end
