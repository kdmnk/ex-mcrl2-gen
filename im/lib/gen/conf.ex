defmodule Conf do
  def getConf() do
    %{"asd" => %{
      :messageType => :Nat,
      :processes => Im.Loader.load_config()
    }}
  end
end
