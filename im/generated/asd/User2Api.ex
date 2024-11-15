defmodule User2Api do
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

  def init() do
    if Process.whereis(User2) do
      GenServer.stop(User2)
    end

    {:ok, pid} = GenServer.start_link(User2, [], name: User2)
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
    %InitState{pid: pid}
  end

  def wait(%InitState{}) do
    IO.inspect("User2: wait called")
    GenServer.call(__MODULE__, :wait)
  end

  def chooseAnswer(%ChoiceState{}, choice) do
    GenServer.cast(User2, {:chooseAnswer, choice})
  end

  def init(_) do
    {:ok, {%{}, nil}}
  end

  def handle_call(:wait, from, {%ChoiceState{} = choiceState, true}) do
    IO.inspect("User2: started waiting. Replying with already updated state.")
    {:reply, choiceState, {%{}, nil}}
  end

  def handle_call(:wait, from, {state, nil}) do
    IO.inspect("User2: started waiting.")
    {:noreply, {state, from}}
  end

  def handle_cast(%ChoiceState{} = choiceState, {state, waiting}) do
    if waiting do
      IO.inspect("User2: replying to wait")
      GenServer.reply(waiting, choiceState)
      {:noreply, {%{}, nil}}
    else
      {:noreply, {choiceState, true}}
    end

  end

end
