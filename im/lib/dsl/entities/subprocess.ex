defmodule Dsl.Entities.SubProcess do
  def process, do: %Spark.Dsl.Entity{
    name: :subprocess,
    describe: "A subprocess.",
    args: [:process, :name, :arg],
    target:  Processes.SubProcess,
    schema: [
      process: [
        type: :atom
      ],
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
      Dsl.Entities.IfCmd.cmd,
      Dsl.Entities.ReceiveCmd.cmd,
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.CallCmd.cmd,
      Dsl.Entities.CallRecurseCmd.cmd,
    ]],
    transform: {__MODULE__, :transform_run, []}
  }

  @spec transform_run(__MODULE__) :: {:ok, __MODULE__}
  def transform_run(entity) do
    state = Enum.map(entity.arg, fn
      {name, {:pid, pidName}} -> {name, {:pid, String.replace_prefix(to_string(pidName), "Elixir.", "")}}
      v -> v
    end)
    process = String.replace_prefix(to_string(entity.process), "Elixir.", "")

    {:ok, %{entity | arg: state, process: process}}
  end

end
