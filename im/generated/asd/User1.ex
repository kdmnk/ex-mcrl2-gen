defmodule User1 do
  use GenServer

  def init(_arg) do
    {:ok, %{}}
  end

  def handle_cast(:start, state) do
    state = %{}
    {:noreply, state}
  end

  def handle_cast({:chooseAnswer, true}, state) do
    IO.puts("User1: sending #{inspect(1)} to #{inspect(Map.get(state, :server))}")
    GenServer.cast(Map.get(state, :server), {self(), 1})
    {:noreply, state}
  end

  def handle_cast({:chooseAnswer, false}, state) do
    IO.puts("User1: sending #{inspect(2)} to #{inspect(Map.get(state, :server))}")
    GenServer.cast(Map.get(state, :server), {self(), 2})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when m == 0 do
    IO.puts("User1: received #{inspect(m)} from #{inspect(server)} and 'm == 0' holds")
    state = %{:m => m, :server => server}
    GenServer.cast(User1Api, %User1Api.ChoiceState{choice: :chooseAnswer, vars: state})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when m == 3 do
    IO.puts("User1: received #{inspect(m)} from #{inspect(server)} and 'm == 3' holds")
    state = %{:m => m, :server => server}
    IO.puts("User1: sending #{inspect(4)} to #{inspect(Map.get(state, :server))}")
    GenServer.cast(Map.get(state, :server), {self(), 4})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when m == 5 do
    IO.puts("User1: received #{inspect(m)} from #{inspect(server)} and 'm == 5' holds")
    state = %{:m => m, :server => server}
    IO.puts("User1: sending #{inspect(4)} to #{inspect(Map.get(state, :server))}")
    GenServer.cast(Map.get(state, :server), {self(), 4})
    {:noreply, state}
  end

end
