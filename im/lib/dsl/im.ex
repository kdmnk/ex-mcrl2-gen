defmodule Im.Dsl.Im do
  use Spark.Dsl

  def messageType(), do: {:or, [:atom, :string, :integer]}

end
