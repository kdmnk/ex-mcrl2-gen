defmodule SimpleCluster.MachApi do
  alias SimpleCluster
  use GenServer

  defmodule InitState do
    defstruct []
  end

  defmodule IdleState do
    defstruct []
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init() do
    %InitState{}
  end

  def start() do
    GenServer.cast({SimpleCluster.Mach, :"mach@127.0.0.1"}, :start)
    %IdleState{}
  end

  def init(_) do
    {:ok, {nil, nil}}
  end

end
