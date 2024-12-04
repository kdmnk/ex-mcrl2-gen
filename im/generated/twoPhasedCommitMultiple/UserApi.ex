defmodule UserApi do
  use GenServer

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule IdleState do
    defstruct [:pid]
  end

  defmodule ChoiceChooseAnswerState do
    defstruct [:pid, :choice, :vars]
  end

  def init() do
    if Process.whereis(User) do
      GenServer.stop(User)
    end

    {:ok, pid} = GenServer.start_link(User, %{})
    GenServer.start_link(__MODULE__, [])
    %InitState{pid: pid}
  end

  def start(%InitState{pid: pid}) do
    GenServer.cast(pid, :start)
    %IdleState{pid: pid}
  end

  def wait(%IdleState{pid: pid}) do
    GenServer.call(__MODULE__, {:wait, pid})
  end

  def chooseChooseAnswer(%ChoiceChooseAnswerState{}, choice) do
    GenServer.cast(User, {:chooseAnswer, choice})
    %IdleState{}
  end

  def init(_) do
    {:ok, {nil, nil}}
  end

  def handle_call(:wait, _from, {choiceState, nil}) when not is_nil(choiceState) do
    IO.puts("UserApi: Started waiting. Replying with already updated state.")
    {:reply, choiceState, {nil, nil}}
  end

  def handle_call(:wait, from, {nil, nil}) do
    IO.puts("UserApi: Started waiting.")
    {:noreply, {nil, from}}
  end

  def handle_cast({:new_choice, choiceState},{nil, nil}) do
    IO.puts("UserApi: got new state but client is not waiting yet")
    {:noreply, {choiceState, nil}}
  end

  def handle_cast({:new_choice, choiceState},{nil, from}) do
    IO.puts("UserApi: replying to wait")
    GenServer.reply(from, choiceState)
    {:noreply, {nil, nil}}
  end

end
