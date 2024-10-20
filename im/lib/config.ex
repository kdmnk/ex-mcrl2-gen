defmodule Im.Config do
  use Im.Dsl.Im,
    extensions: [Im.Dsl.Root]

  #variables
  user = :user
  server = :server
  m = :m

  messageType :Nat

  process User, %{} do
    rcv {m, server} do
      ifcond m == 1 do
        choice "chooseAnswer" do
          snd server, 2
          snd server, 3
        end
      end
    end
  end

  process Mach, %{user => {:pid, User}} do
    snd user, 1
    rcv {m, user} do
      ifcond m == 2, do: (snd user, 3)
      ifcond m == 3, do: (snd user, 4)
    end
  end
end
