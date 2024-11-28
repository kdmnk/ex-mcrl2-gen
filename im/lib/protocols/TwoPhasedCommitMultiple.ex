defmodule Protocols.TwoPhasedCommitMultiple do
  use Dsl.Im,
    extensions: [Dsl.Root]

  #variables
  users = :users
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
  lossyNetwork true

  process User, %{}, 3 do
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
    recurse! do: nil
  end

  process Mach, %{users => {:list, {:pid, User}}}, 1 do
    send! users, commitRequest
    call! "receiveMessages", [[], length(list)]
  end

  subprocess Mach, "receiveMessages", %{:msgs => {:list, :Nat}, :remaining => :Int} do
    if! remaining == 0 do
      then! do
        call! "processAck", [:msgs]
      end
      else! do
        call! "receiveMsg", [:msgs, :remaining]
      end
    end
  end

  subprocess Mach, "receiveMsg", %{:msgs => {:list, :Nat}, :remaining => :Int} do
    rcv! {m, some_user} do
      when! m == 1 or m == 2 do
        call! "receiveMessages", [[m | :msgs], :remaining-1]
      end
    end
  end

  subprocess Mach, "receiveAcks", %{:msgs => {:list, :Nat}, :remaining => :Int} do
    if! remaining == 0 do
      then! do
        recurse! do: nil
      end
      else! do
        call! "receiveAck", [:msgs, :remaining]
      end
    end
  end

  subprocess Mach, "receiveAck", %{:msgs => {:list, :Nat}, :remaining => :Int} do
    rcv! {m, some_user} do
      when! m == 4 do
        call! "receiveAcks", [[m | :msgs], :remaining-1]
      end
    end
  end

  subprocess Mach, "processAck", %{:msgs => {:list, :Nat}} do
    if! 2 in msgs do
      then! do
        send! users, rollback
      end
      else! do
        send! users, commitMessage
      end
    end
    call! "receiveAcks", [[m | :msgs], :remaining-1]
  end


end
