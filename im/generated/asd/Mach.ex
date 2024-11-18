defmodule Mach do
  use GenServer


  def init(vars) do
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    IO.puts("Mach: sending #{inspect(0)} to #{inspect(Map.get(state, :user1))}")
    GenServer.cast(Map.get(state, :user1), {self(), 0})
    IO.puts("Mach: sending #{inspect(0)} to #{inspect(Map.get(state, :user2))}")
    GenServer.cast(Map.get(state, :user2), {self(), 0})
    receiveMessages(state, Map.get(state, :user1), Map.get(state, :user2), [], 2)
  end

  def handle_cast({some_user, m}, state) when m == 1 or m == 2 do
    IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 1 or m == 2' holds")
    receiveMessages(state, Map.get(state, :user1), Map.get(state, :user2), [m | Map.get(state, :msgs)], Map.get(state, :remaining) - 1)
  end

  def handle_cast({some_user, m}, state) when m == 4 do
    IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 4' holds")
    {:noreply, state}
  end

  def receiveMessages(state, user1, user2, msgs, remaining) do
    if (remaining == 0) do
      processAck(state, user1, user2, msgs)
    else
      receiveMsg(state, user1, user2, msgs, remaining)
    end

  end

  def receiveMsg(state, user1, user2, msgs, remaining) do
    state = %{
      :user1 => user1,
      :user2 => user2,
      :msgs => msgs,
      :remaining => remaining
    }
    {:noreply, state}
  end

  def processAck(state, user1, user2, msgs) do
    if (2 in msgs) do
      IO.puts("Mach: sending #{inspect(5)} to #{inspect(Map.get(state, :user1))}")
      GenServer.cast(Map.get(state, :user1), {self(), 5})
      IO.puts("Mach: sending #{inspect(5)} to #{inspect(Map.get(state, :user2))}")
      GenServer.cast(Map.get(state, :user2), {self(), 5})
    end

    if (!(2 in msgs)) do
      IO.puts("Mach: sending #{inspect(3)} to #{inspect(Map.get(state, :user1))}")
      GenServer.cast(Map.get(state, :user1), {self(), 3})
      IO.puts("Mach: sending #{inspect(3)} to #{inspect(Map.get(state, :user2))}")
      GenServer.cast(Map.get(state, :user2), {self(), 3})
    end
    {:noreply, state}
  end

end
