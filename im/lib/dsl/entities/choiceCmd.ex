defmodule Dsl.Entities.ChoiceCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :choice!,
    describe: "Non deterministic choice.",
    target: Commands.Choice,
    args: [:name, :values],
    schema: [
      name: [
        type: :atom
      ],
      values: [
        type: {:or, [
          {:tuple, [:integer, :integer]},
          {:list, {:or, [:boolean, :integer]}}
        ]}
      ]
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.Mcrl2StateCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
    ]],
    transform: {__MODULE__, :transform_run, []}
  }

  @spec transform_run(__MODULE__) :: {:ok, __MODULE__}
  def transform_run(entity) do
    case entity.values do
      {from, to} -> {:ok, %{entity | values: Range.new(from, to)}}
      _value -> {:ok, entity}
    end
  end

end
