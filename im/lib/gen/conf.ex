defmodule Conf do
  def getConf(protocol) do
   %{
      :messageType => Spark.Dsl.Extension.get_opt(protocol, :root, :messageType),
      :lossyNetwork => Spark.Dsl.Extension.get_opt(protocol, :root, :lossyNetwork),
      :allowCrash => Spark.Dsl.Extension.get_opt(protocol, :root, :allowCrash),
      :doneRequirement => Spark.Dsl.Extension.get_opt(protocol, :root, :doneRequirement),
      :customLabels => Spark.Dsl.Extension.get_opt(protocol, :root, :customLabels),
      :fifoNetwork => Spark.Dsl.Extension.get_opt(protocol, :root, :fifoNetwork),
      :processes => Spark.Dsl.Extension.get_entities(protocol, :root)
    }
  end
end
