defmodule Dsl.Entities.Process do
  def process, do: %Spark.Dsl.Entity{
    name: :process,
    describe: "A process that defines commands.",
    args: [:identifier, :state, :quantity],
    target: Entities.Process,
    schema: [
      identifier: [
        type: :atom
      ],
      state: [
        type: {:map, :atom, {:or, [:atom, {:tuple, [:atom, {:or, [:atom, {:tuple, [:atom, :atom]}]}]}]}},
        doc: "Initial arguments for the process."
      ],
      quantity: [
        type: :integer,
        doc: "Number of processes to generate (only for mCRL2)."
      ]
    ],
    entities: [
      states: [
        Dsl.Entities.State.cmd
      ],
      init: [
        Dsl.Entities.Init.cmd
      ]
    ],
    transform: {__MODULE__, :transform_run, []}
  }

  def transform_run(entity) do
    id = String.replace_prefix(to_string(entity.identifier), "Elixir.", "")
    state = Enum.map(entity.state, fn
      {name, {:pid, pidName}} -> {name, {:pid, String.replace_prefix(to_string(pidName), "Elixir.", "")}}
      {name, {:list, {:pid, pidName}}} -> {name, {:list, {:pid, String.replace_prefix(to_string(pidName), "Elixir.", "")}}}
      v -> v
    end)
    {:ok, %{entity | identifier: id, state: state}}
  end
end
