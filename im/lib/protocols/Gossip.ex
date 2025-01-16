defmodule Protocols.Gossip do
  use Dsl.Im,
    extensions: [Dsl.Root]

  messageType :Nat
  lossyNetwork false

  process Client, %{:clients => {:list, {:pid, Client}}, :gossip => :Nat}, 5 do
    init do
      choice! :recipient, {1, 5} do
        send! index(:clients, :recipient), :gossip
        state! :wait_for_gossip, [{:gossip}, {:recipient}]
      end
    end
    state :wait_for_gossip, %{:gossips => {:set, :Nat}, :sent => {:set, :Nat}} do
      rcv! :new_gossip, length(:gossips) < 4 do
        choice! :recipient, {1, 5} do
          if! !(:recipient in :sent) do
            then! do
              send! index(:clients, :recipient), :gossip
              state! :wait_for_gossip, [{:new_gossip} + :gossips, {:recipient} + :sent]
            end
          end
        end
      end
      rcv! :new_gossip, length(:gossips) == 4 do
        mcrl2! :protocolDone, []
        state! :wait_for_gossip, [{:new_gossip} + :gossips, :sent]
      end
    end
  end
end
