defmodule User do
  use GenServer

  def init(vars) do
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    # Continues from a receive block...
    {:noreply, state}
  end

  def handle_cast({:chooseAnswer, true}, state) do
    IO.puts("User: sending #{inspect(1)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {self(), 1})
    {:noreply, state}
  end

  def handle_cast({:chooseAnswer, false}, state) do
    IO.puts("User: sending #{inspect(2)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {self(), 2})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when m == 0 do
    IO.puts("User: received #{inspect(m)} from #{inspect(server)} and 'm == 0' holds")
    state = updateState(state, %{:m => m, :server => server})
    GenServer.cast(UserApi, {:new_choice, %UserApi.ChoiceChooseAnswerState{choice: :chooseAnswer, vars: state}})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when m == 3 do
    IO.puts("User: received #{inspect(m)} from #{inspect(server)} and 'm == 3' holds")
    state = updateState(state, %{:m => m, :server => server})
    IO.puts("User: sending #{inspect(4)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {self(), 4})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when m == 5 do
    IO.puts("User: received #{inspect(m)} from #{inspect(server)} and 'm == 5' holds")
    state = updateState(state, %{:m => m, :server => server})
    IO.puts("User: sending #{inspect(4)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {self(), 4})
    {:noreply, state}
  end

  defp updateState(state, new_map) do
    Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  defp var(state, key) do
    Map.get(state, key, key)
  end

end

