defmodule Dsl.Entities.ReceiveCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :rcv!,
    describe: "Receive command.",
    target: Commands.Receive,
    args: [:value, :condition],
    schema: [
      value: [
        type: {:or, [:atom, {:tuple, [{:or, [:atom, :nil]}, :atom]}]},
        doc: "Variable name for received value",
      ],
      condition: [
        type: :quoted,
      ]
    ],
    entities: [body: [
      Dsl.Entities.SendCommand.cmd,
      Dsl.Entities.BroadcastCmd.cmd,
      Dsl.Entities.ChoiceCmd.cmd,
      Dsl.Entities.Mcrl2StateCmd.cmd,
      Dsl.Entities.ChangeStateCmd.cmd,
      Dsl.Entities.IfCmd.cmd,
    ]],
    transform: {__MODULE__, :transform_run, []}
  }

  @spec transform_run(__MODULE__) :: {:ok, __MODULE__}
  def transform_run(entity) do
    case entity.value do
      {value, from} -> {:ok, %{%{entity | value: value} | from: from }}
      _value -> {:ok, entity}
    end
  end

end
