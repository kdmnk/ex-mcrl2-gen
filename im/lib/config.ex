defmodule Im.Config do
  use Im.DSL.Im,
    extensions: [Im.DSL.ImExtension]

  messageType :Nat

  process "User" do
    state %{
      "serverPid" => {:pid, "Mach"}
    }

    run [
      {:send, to: "serverPid", message: 1},
      {:receive, from: "serverPid"}
    ]
  end

  process "Mach" do
    state %{}

    run [
      {:receive, from: "p", message: "m"},
      {:send, to: "p", message: "m+1"}
    ]
  end
end
