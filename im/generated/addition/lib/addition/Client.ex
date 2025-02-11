defmodule Client do
  use GenServer
  require Logger

  def start_link(vars) do
    GenServer.start_link(__MODULE__, vars, name: __MODULE__)
  end

  def init(vars) do
    vars = %{:server => var(vars, :server)}
    Logger.info("Client: initialised with #{inspect(vars)}")
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    {:ok, timer} =
      :timer.apply_after(:rand.uniform(10000), fn -> GenServer.cast(__MODULE__, :timeout) end)

    state = Map.put(state, :timer, timer)
    Logger.info("Client: sending #{inspect(1)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {{__MODULE__, Node.self()}, 1})

    state = updateState(state, %{:state => :wait_for_answer})
    {:noreply, state}
  end

  def handle_cast({server, n}, state) when state.state == :wait_for_answer and n == 2 do
    Logger.info(
      "Client [wait_for_answer]: received #{inspect(n)} from #{inspect(server)} (n == 2)"
    )

    state = updateState(state, %{:n => n, :server => server})
    Logger.info("Client [wait_for_answer]: state: protocolDone")
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
