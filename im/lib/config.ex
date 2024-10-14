defmodule Im.Config do
  use Im.DSL.Im,
    extensions: [Im.DSL.ImExtension]

  messageType :Nat

  process User, %{
    "server" => {:pid, Mach}
  } do
    snd "server", 1
    rcv "server", 2
  end

  process Mach, %{} do
    snd "m", 1
    rcv "m", 2
  end
end
