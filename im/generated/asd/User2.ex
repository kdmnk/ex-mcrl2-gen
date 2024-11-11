defmodule User2 do
  use GenServer

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule ChoiceState do
    defstruct [:choice, :vars]
  end

  defmodule DoneState do
    defstruct []
  end

  def start() do
    if Process.whereis(__MODULE__) do
      GenServer.stop(__MODULE__)
    end

    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
    %InitState{pid: pid}
  end

  def wait(%InitState{}) do
    GenServer.call(__MODULE__, :wait)
  end

  def chooseAnswer(%ChoiceState{}, choice) do
    GenServer.call(__MODULE__, {:chooseAnswer, choice})
  end

  def init(_arg) do
    {:ok, {%{}, nil}}
  end

  def handle_call(:wait, from, {state, true}) do
    {:reply, state, {state, nil}}
  end

  def handle_call(:wait, from, {state, nil}) do
    {:noreply, {state, from}}
  end

  def handle_call({:chooseAnswer, true}, _from, {state, waiting}) do
    IO.puts("User2: sending #{inspect(1)} to #{inspect(Map.get(state.vars, :server))}")
    send(Map.get(state.vars, :server), {self(), 1})
    {:reply, %DoneState{}, {%DoneState{}, waiting}}
  end

  def handle_call({:chooseAnswer, false}, _from, {state, waiting}) do
    IO.puts("User2: sending #{inspect(2)} to #{inspect(Map.get(state.vars, :server))}")
    send(Map.get(state.vars, :server), {self(), 2})
    {:reply, %DoneState{}, {%DoneState{}, waiting}}
  end

  def handle_cast({server, m}, {state, waiting}) when m == 0 do
    IO.puts("User2: received #{inspect(m)} from #{inspect(server)} and 'm == 0' holds")
    state = %ChoiceState{choice: :chooseAnswer, vars: %{:m => m, :server => server}}
    if waiting do
      GenServer.reply(waiting, state)
    end

    waiting = true
    {:noreply, {state, waiting}}
  end

  def handle_cast({server, m}, {state, waiting}) when m == 3 do
    IO.puts("User2: received #{inspect(m)} from #{inspect(server)} and 'm == 3' holds")
    IO.puts("User2: sending #{inspect(4)} to #{inspect(Map.get(state.vars, :server))}")
    send(Map.get(state.vars, :server), {self(), 4})
    {:noreply, {state, waiting}}
  end

  def handle_cast({server, m}, {state, waiting}) when m == 5 do
    IO.puts("User2: received #{inspect(m)} from #{inspect(server)} and 'm == 5' holds")
    IO.puts("User2: sending #{inspect(4)} to #{inspect(Map.get(state.vars, :server))}")
    send(Map.get(state.vars, :server), {self(), 4})
    {:noreply, {state, waiting}}
  end

end

