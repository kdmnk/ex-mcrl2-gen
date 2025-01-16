defmodule Protocols.Raft do
  use Dsl.Im,
    extensions: [Dsl.Root]

  messageType %{t: :Nat, data: :Nat}
  lossyNetwork false
  allowCrash true

  process Candidate, %{:others => {:list, {:pid, Candidate}}}, 5 do
    init do
      state! :idle, [0]
    end
    state :candidate_wait_ack, %{:term => :Nat, :remaining_good => :Int, :allowed_bad => :Int} do
      # ignore messages with older terms
      rcv! {:m, :some_user}, t(:m) < :term do
        state! :candidate_wait_ack, [:term, :remaining_good, :allowed_bad]
      end
      # receive approve vote
      rcv! {:m, :some_user}, data(:m) == 1 and :remaining_good > 1 and t(:m) == :term do
        state! :candidate_wait_ack, [:term, :remaining_good - 1, :allowed_bad]
      end
      # receive last approve vote
      rcv! {:m, :some_user}, data(:m) == 1 and :remaining_good == 1 and t(:m) == :term do
        broadcast! :others, {:term, 5}
        state! :idle, [:term]
      end
      # receive decline vote
      rcv! {:m, :some_user}, data(:m) == 2 and :allowed_bad > 0 and t(:m) == :term do
        state! :candidate_wait_ack, [:term, :remaining_good, :allowed_bad - 1]
      end
      # receive last decline vote
      rcv! {:m, :some_user}, data(:m) == 2 and :allowed_bad == 0 and t(:m) == :term do
        state! :idle, [:term]
      end
      # receive vote request from others in same term
      rcv! {:m, :candidate}, data(:m) == 0 and :candidate != self() and t(:m) == :term do
        send! :candidate, {:term, 2}
        state! :candidate_wait_ack, [:term, :remaining_good, :allowed_bad]
      end
      # receive vote request from others in higher term
      rcv! {:m, :candidate}, data(:m) == 0 and :candidate != self() and t(:m) > :term do
        send! :candidate, {t(:m), 1}
        state! :idle, [t(:m)]
      end
      # receive vote request from self (any term)
      rcv! {:m, :candidate}, data(:m) == 0 and :candidate == self() do
        send! :candidate, {t(:m), 1}
        state! :candidate_wait_ack, [:term, :remaining_good, :allowed_bad]
      end
      # receive new leader
      rcv! {:m, :candidate}, data(:m) == 5 and t(:m) >= :term do
        mcrl2! :protocolDone, []
      end
    end
    state :idle, %{:term => :Nat} do
      # receive vote request (higher term)
      rcv! {:m, :candidate}, data(:m) == 0 and t(:m) > :term do
        send! :candidate, {t(:m), 1} # approve
        state! :idle, [t(:m)]
      end
      # receive vote request (same term)
      rcv! {:m, :candidate}, data(:m) == 0 and t(:m) == :term do
        send! :candidate, {t(:m), 2} # decline
        state! :idle, [:term]
      end
      # ignore messages with lower term
      rcv! {:m, :candidate}, t(:m) < :term do
        state! :idle, [:term]
      end
      # receive new leader
      rcv! {:m, :candidate}, data(:m) == 5 and t(:m) >= :term do
        mcrl2! :protocolDone, []
      end
      timeout do
        broadcast! :others, {:term+1, 0}
        state! :candidate_wait_ack, [:term + 1, ceil(length(:others) / 2), floor(length(:others) / 2)]
      end
    end
  end
end
