defmodule Im.Loader do
  alias Spark.Dsl.Extension

  def load_config do
    Spark.Dsl.Extension.get_entities(Im.Config, :root)
  end
end
