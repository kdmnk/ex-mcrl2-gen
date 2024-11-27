defmodule Dsl.Entities.CallRecurseCmd do

  def cmd(), do: %Spark.Dsl.Entity{
    name: :recurse!,
    describe: "Continue executing the current process from the beginning",
    target: Commands.Recurse,
    args: [],
    schema: [],
    entities: [],
  }
end
