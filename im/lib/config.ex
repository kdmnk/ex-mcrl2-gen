defmodule Im.Config do
  use Im.Dsl.Im,
    extensions: [Im.Dsl.Root]

  #variables
  user1 = :user1
  user2 = :user2
  some_user = :some_user
  server = :server
  m = :m

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
    call "receiveMessages", [[], 2]
  end

  subprocess "receiveMessages", [:msgs, :remaining] do
    ifcond remaining == 0 do
      call "processAck", [:msgs]
    end
    ifcond remaining > 0 do
      call "receiveMessage", [:msgs, :remaining]
    end
  end

  subprocess "receiveMessage", [:msgs, :remaining] do
    rcv {m, some_user} do
      ifcond true do
        call "receiveMessages", [[m | :msgs], :remaining-1]
      end
    end
  end

  subprocess "processAck", [:msgs] do
    ifcond 2 in msgs do
      snd user1, rollback
      snd user2, rollback
    end
    ifcond true do
      snd user1, commitMessage
      snd user2, commitMessage
    end
  end
end
