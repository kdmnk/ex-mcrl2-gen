defmodule Im.Config do
  use Im.DSL.Im,
    extensions: [Im.DSL.ImExtension]

  messageType :Nat

  process User, %{} do
    rcv {"m", "server"} do
      choice "chooseAnswer" do
        snd "server", 1
        snd "server", 2
      end
    end
  end

  process Mach, %{"user" => {:pid, User}} do
    snd "user", 0
    rcv {"m", "user"} do
      match 1, do: (snd "user", 3)
      match 2, do: (snd "user", 4)
    end
  end
end
