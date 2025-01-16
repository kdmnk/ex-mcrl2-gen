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
