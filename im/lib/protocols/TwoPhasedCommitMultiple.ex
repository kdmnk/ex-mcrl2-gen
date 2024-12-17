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
          recurse! do: nil
        end
        when! :m == 4 do
          send! :server, 5
          recurse! do: nil
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
          set! :msgs, [:m | :msgs]
          set! :remaining, :remaining-1
        end
        when! (:m == 1 or :m == 2) and :remaining == 1 do
          set! :msgs, [:m | :msgs]
          if! 1 in :msgs do
            broadcast! :users, 3
            state! :receive_acks, [length(:users)]
          end
          if! !(1 in :msgs) do
            broadcast! :users, 4
          end
        end
      end

    end
    state :receive_acks, %{:remaining => :Int} do
      rcv! {:m, :some_user} do
        when! :m == 5 and :remaining > 1  do
          set! :remaining, :remaining -1
        end
        when! :m == 5 and :remaining == 1 do
          mcrl2! :done
          recurse! do: nil
        end
      end
    end
  end
end
