defmodule Im.Loader do
  def load_config do
    Spark.Dsl.Extension.get_entities(Im.Config, :root)
  end
end
