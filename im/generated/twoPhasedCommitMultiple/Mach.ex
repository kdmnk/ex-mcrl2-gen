defmodule Mach do
  use GenServer

  def init(vars) do
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    IO.puts("Mach: sending #{inspect(0)} to #{inspect(var(state, :users))}")
    GenServer.cast(var(state, :users), {self(), 0})
    state = updateState(state, %{:msgs => [], :remaining => length((users))})
    state = receiveMessages(state)
    {:noreply, state}
  end

  def handle_cast({some_user, m}, state) when m == 1 or m == 2 do
    IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 1 or m == 2' holds")
    state = updateState(state, %{:m => m, :some_user => some_user})
    state = updateState(state, %{:msgs => [var(state, :m) | var(state, :msgs)], :remaining => var(state, :remaining) - 1})
    state = receiveMessages(state)
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
      IO.puts("Mach: sending #{inspect(5)} to #{inspect(var(state, :users))}")
      GenServer.cast(var(state, :users), {self(), 5})
      state
    else
      IO.puts("Mach: sending #{inspect(3)} to #{inspect(var(state, :users))}")
      GenServer.cast(var(state, :users), {self(), 3})
      state
    end

    state = updateState(state, %{:remaining => length((users))})
    state = waitForAcks(state)
    state
  end

  def waitForAcks(state) do
    state = if (var(state, :remaining) > 0) do
      state = updateState(state, %{:remaining => var(state, :remaining) - 1})
      state = waitForAcks(state)
      state
    else
      state
    end

    state
  end

  defp updateState(state, new_map) do
    Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  defp var(state, key) do
    Map.get(state, key, key)
  end

end

