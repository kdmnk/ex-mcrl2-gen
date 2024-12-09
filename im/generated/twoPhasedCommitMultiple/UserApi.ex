defmodule SimpleCluster.UserApi do
  use GenServer
  alias SimpleCluster
  require Logger

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule IdleState do
    defstruct []
  end

  defmodule ChoiceChooseAnswerState do
    defstruct [:choice, :vars]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init() do
    %InitState{pid: self()}
  end

  def start() do
    GenServer.cast({User1, Node.self()}, :start)
    %IdleState{}
  end

  def wait() do
    GenServer.call({__MODULE__, Node.self()}, :wait, :infinity)
  end

  def chooseChooseAnswer(%ChoiceChooseAnswerState{}, choice) do
    GenServer.cast({User1, Node.self()}, {:chooseAnswer, choice})
    %IdleState{}
  end

  def init(_) do
    {:ok, {nil, nil}}
  end

  def handle_call(:wait, _from, {choiceState, nil}) when not is_nil(choiceState) do
    Logger.info("User1Api: Started waiting. Replying with already updated state.")
    {:reply, choiceState, {nil, nil}}
  end

  def handle_call(:wait, from, {nil, nil}) do
    Logger.info("User1Api: Started waiting.")
    {:noreply, {nil, from}}
  end

  def handle_cast({:new_choice, choiceState},{nil, nil}) do
    Logger.info("User1Api: got new state but client is not waiting yet")
    {:noreply, {choiceState, nil}}
  end

  def handle_cast({:new_choice, choiceState},{nil, from}) do
    Logger.info("User1Api: replying to wait")
    GenServer.reply(from, choiceState)
    {:noreply, {nil, nil}}
  end

end
