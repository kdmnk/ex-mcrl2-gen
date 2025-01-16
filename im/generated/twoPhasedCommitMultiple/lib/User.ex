defmodule User do
  use GenServer
  require Logger

  def start_link(vars) do
    GenServer.start_link(__MODULE__, vars, name: __MODULE__)
  end

  def init(vars) do
    vars = %{}
    Logger.info("User: initialised with #{inspect(vars)}")
    {:ok, vars}
  end

  def handle_cast(:start, state) do
    state = updateState(state, %{:state => :idle})
    {:noreply, state}
  end

  def handle_cast({:chooseAnswer, true}, state) do
    Logger.info("User: sending #{inspect(1)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {{__MODULE__, Node.self()}, 1})

    {:noreply, state}
  end

  def handle_cast({:chooseAnswer, false}, state) do
    Logger.info("User: sending #{inspect(2)} to #{inspect(var(state, :server))}")
    GenServer.cast(var(state, :server), {{__MODULE__, Node.self()}, 2})

    {:noreply, state}
  end

  def handle_cast({server, m}, state) when state.state == :idle and m == 0 do
    Logger.info("User [idle]: received #{inspect(m)} from #{inspect(server)} (m == 0)")
    state = updateState(state, %{:m => m, :server => server})

    GenServer.cast(
      {UserApi, Node.self()},
      {:new_choice, %UserApi.ChoiceChooseAnswerState{choice: :chooseAnswer, vars: state}}
    )

    state = updateState(state, %{:state => :wait_for_server})
    {:noreply, state}
  end

  def handle_cast({server, m}, state) when state.state == :wait_for_server and m == 3 do
    Logger.info("User [wait_for_server]: received #{inspect(m)} from #{inspect(server)} (m == 3)")
    state = updateState(state, %{:m => m, :server => server})

    Logger.info(
      "User [wait_for_server]: sending #{inspect(5)} to #{inspect(var(state, :server))}"
    )

    GenServer.cast(var(state, :server), {{__MODULE__, Node.self()}, 5})

    {:noreply, state}
  end

  def handle_cast({server, m}, state) when state.state == :wait_for_server and m == 4 do
    Logger.info("User [wait_for_server]: received #{inspect(m)} from #{inspect(server)} (m == 4)")
    state = updateState(state, %{:m => m, :server => server})

    Logger.info(
      "User [wait_for_server]: sending #{inspect(5)} to #{inspect(var(state, :server))}"
    )

    GenServer.cast(var(state, :server), {{__MODULE__, Node.self()}, 5})

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
