defmodule Conf do
  def getConf(protocol) do
   %{
      :messageType => Spark.Dsl.Extension.get_opt(protocol, :root, :messageType),
      :lossyNetwork => Spark.Dsl.Extension.get_opt(protocol, :root, :lossyNetwork),
      :processes => Spark.Dsl.Extension.get_entities(protocol, :root)
    }
  end
end
