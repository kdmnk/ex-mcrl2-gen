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
    rcv! {m, server} do
      when! m == 0 do
        choice! "chooseAnswer" do
          send! server, yesResponse
          send! server, noResponse
        end
      end
      when! m == 3 do
        send! server, ack
      end
      when! m == 5 do
        send! server, ack
      end
    end
  end

  process User2, %{} do
    rcv! {m, server} do
      when! m == 0 do
        choice! "chooseAnswer" do
          send! server, yesResponse
          send! server, noResponse
        end
      end
      when! m == 3 do
        send! server, ack
      end
      when! m == 5 do
        send! server, ack
      end
    end
  end

  process Mach, %{user1 => {:pid, User1}, user2 => {:pid, User2}} do
    send! user1, commitRequest
    send! user2, commitRequest
    call! "receiveMessages", [user1, user2, [], 2]
  end

  subprocess Mach, "receiveMessages", %{:user1 => :Pid, :user2 => :Pid, :msgs => {:list, :Nat}, :remaining => :Int} do
    if! remaining == 0 do
      call! "processAck", [:user1, :user2, :msgs]
    end
    if! remaining > 0 do
      call! "receiveMsg", [:user1, :user2, :msgs, :remaining]
    end
  end

  subprocess Mach, "receiveMsg", %{:user1 => :Pid, :user2 => :Pid, :msgs => {:list, :Nat}, :remaining => :Int} do
    rcv! {m, some_user} do
      when! true do
        call! "receiveMessages", [:user1, :user2, [m | :msgs], :remaining-1]
      end
    end
  end

  subprocess Mach, "processAck", %{:user1 => :Pid, :user2 => :Pid, :msgs => {:list, :Nat}} do
    if! 2 in msgs do
      send! user1, rollback
      send! user2, rollback
    end
    if! !(2 in msgs) do
      send! user1, commitMessage
      send! user2, commitMessage
    end
  end
end
