defmodule SimpleCluster.Mach do
  alias Hex.API.User
  alias SimpleCluster
  use GenServer
  require Logger

  def start_link(vars) do
    Logger.info("Mach started with #{inspect(vars)}")
    GenServer.start_link(__MODULE__, vars, name: __MODULE__)
  end

  def init(vars) do
    Logger.info("Mach initialised with #{inspect(vars)}")
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    Logger.info("Mach: sending #{inspect(0)} to #{inspect(var(state, :user1))}")
    GenServer.cast(var(state, :user1), {Node.self(), 0})
    Logger.info("Mach: sending #{inspect(0)} to #{inspect(var(state, :user2))}")
    GenServer.cast(var(state, :user2), {Node.self(), 0})
    state = updateState(state, %{:msgs => [], :remaining => 2})
    state = receiveMessages(state)
    {:noreply, state}
  end

  def handle_cast({some_user, m}, state) when m == 1 or m == 2 do
    Logger.info("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 1 or m == 2' holds")
    state = updateState(state, %{:m => m, :some_user => some_user})
    state = updateState(state, %{:msgs => [var(state, :m) | var(state, :msgs)], :remaining => var(state, :remaining) - 1})
    state = receiveMessages(state)
    {:noreply, state}
  end

  def handle_cast({some_user, m}, state) when m == 4 do
    Logger.info("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 4' holds")
    state = updateState(state, %{:m => m, :some_user => some_user})
    {:noreply, state}
  end

  def handle_cast({some_user, m}, state) when m == 4 do
    Logger.info("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 4' holds")
    state = updateState(state, %{:m => m, :some_user => some_user})
    {:noreply, state}
  end

  def receiveMessages(state) do
    state = if (var(state, :remaining) == 0) do
      state = updateState(state, %{:msgs => var(state, :msgs)})
      state = processAck(state)
      state
    else
      state = updateState(state, %{:msgs => var(state, :msgs), :remaining => var(state, :remaining)})
      state = receiveMsg(state)
      state
    end

    state
  end

  def receiveMsg(state) do
    # Continues from a receive block...
    state
  end

  def processAck(state) do
    state = if (2 in var(state, :msgs)) do
      Logger.info("Mach: sending #{inspect(5)} to #{inspect(var(state, :user1))}")
      GenServer.cast(var(state, :user1), {self(), 5})
      Logger.info("Mach: sending #{inspect(5)} to #{inspect(var(state, :user2))}")
      GenServer.cast(var(state, :user2), {self(), 5})
      state
    else
      Logger.info("Mach: sending #{inspect(3)} to #{inspect(var(state, :user1))}")
      GenServer.cast(var(state, :user1), {self(), 3})
      Logger.info("Mach: sending #{inspect(3)} to #{inspect(var(state, :user2))}")
      GenServer.cast(var(state, :user2), {self(), 3})
      state
    end

    # Continues from a receive block...
    state
  end

  defp updateState(state, new_map) do
    Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  defp var(state, key) do
    Map.get(state, key, key)
  end

end
