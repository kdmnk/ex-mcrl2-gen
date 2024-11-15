defmodule MachApi do
  use GenServer

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule ChoiceState do
    defstruct [:choice, :vars]
  end

  defmodule DoneState do
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

  def start() do
    GenServer.cast(Mach, :start)
  end

  def init(_) do
    {:ok, nil}
  end
end
