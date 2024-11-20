defmodule User1Api do
  use GenServer

  defmodule InitState do
    defstruct [:pid]
  end

  defmodule ChoiceChooseAnswerState do
    defstruct [:choice, :vars]
  end

  def init() do
    if Process.whereis(User1) do
      GenServer.stop(User1)
    end

    {:ok, pid} = GenServer.start_link(User1, %{}, name: User1)
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
    %InitState{pid: pid}
  end

  def start(%InitState{}) do
    GenServer.cast(User1, :start)
  end

  def wait() do
    GenServer.call(__MODULE__, :wait)
  end

  def choosechooseAnswer(%ChoiceChooseAnswerState{}, choice) do
    GenServer.cast(User1, {:chooseAnswer, choice})
  end

  def init(_) do
    {:ok, %{choice_state: nil, choice_received: false, waiting_from: nil}}
  end

  def handle_call(:wait, _from, %{choice_state: choiceState, choice_received: true, waiting_from: nil}) do
    IO.puts("User1Api: Started waiting. Replying with already updated state.")
    {:reply, choiceState, %{choice_state: nil, choice_received: false, waiting_from: nil}}
  end

  def handle_call(:wait, from, %{choice_state: nil, choice_received: false, waiting_from: nil}) do
    IO.puts("User1Api: Started waiting.")
    {:noreply, %{choice_state: nil, choice_received: false, waiting_from: from}}
  end

  def handle_cast({:new_choice, choiceState}, %{choice_state: nil, choice_received: false, waiting_from: nil}) do
    {:noreply, %{choice_state: choiceState, choice_received: true, waiting_from: nil}}
  end

  def handle_cast({:new_choice, choiceState}, %{choice_state: nil, choice_received: false, waiting_from: from}) do
    IO.puts("User1Api: replying to wait")
    GenServer.reply(from, choiceState)
    {:noreply, %{choice_state: nil, choice_received: false, waiting_from: nil}}
  end

end
