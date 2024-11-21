defmodule User2Api do
  use GenServer

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule ChoiceChooseAnswerState do
    defstruct [:choice, :vars]
  end

  def init() do
    if Process.whereis(User2) do
      GenServer.stop(User2)
    end

    {:ok, pid} = GenServer.start_link(User2, %{}, name: User2)
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
    %InitState{pid: pid}
  end

  def start(%InitState{}) do
    GenServer.cast(User2, :start)
  end

  def wait() do
    GenServer.call(__MODULE__, :wait)
  end

  def chooseChooseAnswer(%ChoiceChooseAnswerState{}, choice) do
    GenServer.cast(User2, {:chooseAnswer, choice})
  end

  def init(_) do
    {:ok, {nil, nil}}
  end

  def handle_call(:wait, _from, {choiceState, nil}) when not is_nil(choiceState) do
    IO.puts("User2Api: Started waiting. Replying with already updated state.")
    {:reply, choiceState, {nil, nil}}
  end

  def handle_call(:wait, from, {nil, nil}) do
    IO.puts("User2Api: Started waiting.")
    {:noreply, {nil, from}}
  end

  def handle_cast({:new_choice, choiceState},{nil, nil}) do
    IO.puts("User2Api: got new state but client is not waiting yet")
    {:noreply, {choiceState, nil}}
  end

  def handle_cast({:new_choice, choiceState},{nil, from}) do
    IO.puts("User2Api: replying to wait")
    GenServer.reply(from, choiceState)
    {:noreply, {nil, nil}}
  end

end

