defmodule Conf do
  def getConf() do
    %{"twoPhasedCommit" => %{
      :messageType => Spark.Dsl.Extension.get_opt(Protocols.TwoPhasedCommit, :root, :messageType),
      :lossyNetwork => Spark.Dsl.Extension.get_opt(Protocols.TwoPhasedCommit, :root, :lossyNetwork),
      :processes => Spark.Dsl.Extension.get_entities(Protocols.TwoPhasedCommit, :root)
    },
    "twoPhasedCommitMultiple" =>%{
      :messageType => Spark.Dsl.Extension.get_opt(Protocols.TwoPhasedCommitMultiple, :root, :messageType),
      :lossyNetwork => Spark.Dsl.Extension.get_opt(Protocols.TwoPhasedCommitMultiple, :root, :lossyNetwork),
      :processes => Spark.Dsl.Extension.get_entities(Protocols.TwoPhasedCommitMultiple, :root)
    }
  }
  end
end
