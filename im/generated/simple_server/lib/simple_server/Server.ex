defmodule Server do
  use GenServer
  require Logger

  def start_link(vars) do
    GenServer.start_link(__MODULE__, vars, name: __MODULE__)
  end

  def init(vars) do
    vars = %{}
    Logger.info("Server: initialised with #{inspect(vars)}")
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    state = updateState(state, %{:state => :wait_for_number})
    {:noreply, state}
  end

  def handle_cast({some_client, n}, state) when state.state == :wait_for_number and true do
    Logger.info(
      "Server [wait_for_number]: received #{inspect(n)} from #{inspect(some_client)} (true)"
    )

    state = updateState(state, %{:n => n, :some_client => some_client})

    Logger.info(
      "Server [wait_for_number]: sending #{inspect(n + 1)} to #{inspect(var(state, :some_client))}"
    )

    GenServer.cast(var(state, :some_client), {{__MODULE__, Node.self()}, n + 1})

    {:noreply, state}
  end

  defp updateState(state, new_map) do
    Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  defp var(state, key) do
    case Map.get(state, key) do
      nil -> raise "Key #{inspect(key)} not found in state #{inspect(state)}"
      x -> x
    end
  end
end
