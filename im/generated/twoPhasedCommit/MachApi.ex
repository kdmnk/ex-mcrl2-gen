defmodule MachApi do
  use GenServer

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule IdleState do
    defstruct []
  end

  def init(user1, user2) do
    if Process.whereis(Mach) do
      GenServer.stop(Mach)
    end

    {:ok, pid} = GenServer.start_link(Mach, %{:user1 => user1, :user2 => user2}, name: Mach)
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
    %InitState{pid: pid}
  end

  def start(%InitState{}) do
    GenServer.cast(Mach, :start)
    %IdleState{}
  end

  def init(_) do
    {:ok, {nil, nil}}
  end

end

