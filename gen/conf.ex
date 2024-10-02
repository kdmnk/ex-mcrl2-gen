defmodule Conf do
  def getConf() do
    %{
      :messageType => :Nat,
      :processes => [%{
        :name => "User",
        :state => %{
          "serverPid" => {:pid, "Mach"}
        },
        :run => [
          {:send, to: "serverPid", message: 1},
          {:receive, from: "serverPid"}
        ]
      },
      %{
        :name => "Mach",
        :state => %{},
        :run => [
          {:receive, from: "p", message: "m"},
          {:send, to: "p", message: "m+1"}
        ]
      }]
    }
  end
end
