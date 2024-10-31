defmodule Im.Config do
  use Im.Dsl.Im,
    extensions: [Im.Dsl.Root]

  #variables
  user1 = :user1
  user2 = :user2
  some_user = :some_user
  server = :server
  m = :m
  m2 = :m

  commitRequest = 0
  yesResponse = 1
  noResponse = 2

  commitMessage = 3
  ack = 4

  rollback = 5

  messageType :Nat

  process User1, %{} do
    rcv {m, server} do
      ifcond m == 0 do
        choice "chooseAnswer" do
          snd server, yesResponse
          snd server, noResponse
        end
      end
      ifcond m == 3 do
        snd server, ack
      end
      ifcond m == 5 do
        snd server, ack
      end
    end
  end

  process User2, %{} do
    rcv {m, server} do
      ifcond m == 0 do
        choice "chooseAnswer" do
          snd server, yesResponse
          snd server, noResponse
        end
      end
      ifcond m == 3 do
        snd server, ack
      end
      ifcond m == 5 do
        snd server, ack
      end
    end
  end

  process Mach, %{user1 => {:pid, User1}, user2 => {:pid, User2}} do
    snd user1, commitRequest
    snd user2, commitRequest
    rcv {m, some_user} do
      ifcond m == 1 do
        snd user1, commitMessage
        snd user2, commitMessage
      end
      ifcond m == 2 do
        snd user1, rollback
        snd user2, rollback
      end
    end
    rcv {m2, some_user} do
      rcv {m, some_user} do
        snd some_user, rollback
      end
    end
  end
end
