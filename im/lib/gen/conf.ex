defmodule Conf do
  def getConf() do
    %{"asd" => %{
      :messageType => Spark.Dsl.Extension.get_opt(Protocols.TwoPhasedCommit, :root, :messageType),
      :lossyNetwork => Spark.Dsl.Extension.get_opt(Protocols.TwoPhasedCommit, :root, :lossyNetwork),
      :processes => Spark.Dsl.Extension.get_entities(Protocols.TwoPhasedCommit, :root)
    }}
  end
end
