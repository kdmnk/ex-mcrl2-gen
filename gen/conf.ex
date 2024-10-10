defmodule Conf do
  def getConf() do
    %{"circular-3-nodes" => %{
      :messageType => :Nat,
      :processes => [%{
        :name => "User1",
        :state => %{
          "nextPid" => {:pid, "User2"}
        },
        :run => [
          {:send, to: "nextPid", message: 1},
          {:receive}
        ]
      },
      %{
        :name => "User2",
        :state => %{
          "nextPid" => {:pid, "User3"}
        },
        :run => [
          {:receive, from: "user1", message: "m"},
          {:send, to: "nextPid", message: "user1"}
        ]
      },
      %{
        :name => "User3",
        :state => %{},
        :run => [
          {:receive, message: "m"},
          {:send, to: "m", message: "2"}
        ]
      }
    ]
    },
    "return-plus-one" => %{
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
          {:send, to: "p", message: %{:addition => ["m", 1]}}
        ]
      }]
    }
  }
  end
end
