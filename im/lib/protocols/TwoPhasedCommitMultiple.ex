defmodule Protocols.TwoPhasedCommitMultiple do
  use Dsl.Im,
    extensions: [Dsl.Root]

  messageType :Nat
  lossyNetwork false

  process User, %{}, 3 do
    init do
      state! :idle, []
    end
    state :idle do
      rcv! {:m, :server} do
        when! :m == 0 do
          choice! "chooseAnswer" do
            send! :server, 1
            send! :server, 2
          end
          state! :wait_for_server, []
        end
      end
    end
    state :wait_for_server do
      rcv! {:m, :server} do
        when! :m == 3 do
          send! :server, 5
        end
        when! :m == 4 do
          send! :server, 5
        end
      end
    end
  end

  process Mach, %{:users => {:list, {:pid, User}}}, 1 do
    init do
      broadcast! :users, 0
      state! :receive_messages, [[], length(:users)]
    end
    state :receive_messages, %{:msgs => {:list, :Nat}, :remaining => :Int} do
      rcv! {:m, :some_user} do
        when! (:m == 1 or :m == 2) and :remaining > 1 do
          state! :receive_messages, [[:m | :msgs], :remaining-1]
        end
        when! (:m == 1 or :m == 2) and :remaining == 1 do
          if! 1 in [:m | :msgs] do
            then! do
              broadcast! :users, 3
              state! :receive_acks, [length(:users)]
            end
            else! do
              broadcast! :users, 4
              state! :receive_acks, [length(:users)]
            end
          end
        end
      end

    end
    state :receive_acks, %{:remaining => :Int} do
      rcv! {:m, :some_user} do
        when! :m == 5 and :remaining > 1  do
          state! :receive_acks, [:remaining -1]
        end
        when! :m == 5 and :remaining == 1 do
          mcrl2! :protocolDone
        end
      end
    end
  end
end
