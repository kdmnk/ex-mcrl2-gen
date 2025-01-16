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
