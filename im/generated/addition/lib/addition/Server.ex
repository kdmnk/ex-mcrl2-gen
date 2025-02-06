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
    {:ok, timer} =
      :timer.apply_after(:rand.uniform(10000), fn -> GenServer.cast(__MODULE__, :timeout) end)

    state = Map.put(state, :timer, timer)
    state = updateState(state, %{:state => :wait_for_number})
    {:noreply, state}
  end

  def handle_cast({some_client, n}, state) when state.state == :wait_for_number and true do
    Logger.info(
      "Server [wait_for_number]: received #{inspect(n)} from #{inspect(some_client)} (true)"
    )

    state = updateState(state, %{:n => n, :some_client => some_client})

    Logger.info(
      "Server [wait_for_number]: sending #{inspect(var(state, :n) + 1)} to #{inspect(var(state, :some_client))}"
    )

    GenServer.cast(var(state, :some_client), {{__MODULE__, Node.self()}, var(state, :n) + 1})

    {:noreply, state}
  end

  def handle_cast(:timeout, state) do
    # Logger.info(
    #  "Candidate [#{state.state}]: timeout without effect"
    # )
    state = updateState(state, %{})
    {:noreply, state}
  end

  defp updateState(state, new_map) do
    :timer.cancel(var(state, :timer))

    {:ok, timer} =
      :timer.apply_after(:rand.uniform(10000), fn -> GenServer.cast(__MODULE__, :timeout) end)

    state = %{state | timer: timer}
    Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
  end

  defp var(state, key) do
    case Map.get(state, key) do
      nil -> raise "Key #{inspect(key)} not found in state #{inspect(state)}"
      x -> x
    end
  end
end
