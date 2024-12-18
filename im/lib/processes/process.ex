defmodule Processes.Process do
  alias Gen.GenMcrl2
  alias Gen.GenEx

  defstruct [:identifier, :state, :states, :init, :quantity]

  def writeMcrl2(%__MODULE__{} = p, %Gen.GenState{} = state) do
    Gen.Helpers.writeLn(state, "#{p.identifier}(#{Gen.Helpers.getState(state.mcrl2_static_state)}) = ")

    GenMcrl2.writeCmds(
      Gen.GenState.indent(state),
      p.init
    )
    Gen.Helpers.writeLn(state, ";")

    GenMcrl2.writeCmds(
      state,
      p.states,
      ";\n"
    )
    Gen.Helpers.writeLn(state, ";")
  end

  def writeEx(%Gen.GenState{} = state, %Gen.GenState{} = stateApi, %__MODULE__{} = p) do
    choices = Gen.Helpers.getCommands(Commands.Choice, p.states ++ p.init)

    writeApi(stateApi, p, choices)
    writeProcess(state, p, choices)
  end

  defp writeApi(state, p, choices) do
    state = %{state | module_name: p.identifier <> "Api"}

    Gen.Helpers.writeLn(state, """
    defmodule #{p.identifier}Api do
      use GenServer
      require Logger

      defmodule IdleState do
        defstruct []
      end

      #{Enum.map(choices, fn cmd -> """
      defmodule Choice#{Commands.Choice.getStateLabel(cmd)}State do
          defstruct [:choice, :vars]
        end
      """ end)}
      def start_link(_) do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end

      def start() do
        GenServer.cast({#{p.identifier}, Node.self()}, :start)
        %IdleState{}
      end

      #{if(choices != [], do: """
      def wait(%IdleState{}) do
          GenServer.call({__MODULE__, Node.self()}, :wait, :infinity)
        end
      """, else: "")}
      #{Enum.map(choices, fn cmd -> """
      def choose#{Commands.Choice.getStateLabel(cmd)}(%Choice#{Commands.Choice.getStateLabel(cmd)}State{}, choice) do
          GenServer.cast({#{p.identifier}, Node.self()}, {:#{cmd.label}, choice})
          %IdleState{}
        end
      """ end)}
      def init(_) do
        {:ok, {nil, nil}}
      end

      #{if(choices != [], do: """
      def handle_call(:wait, _from, {choiceState, nil}) when not is_nil(choiceState) do
          #{Gen.GenEx.writeLog(state, "Started waiting. Replying with already updated state.")}
          {:reply, choiceState, {nil, nil}}
        end

        def handle_call(:wait, from, {nil, nil}) do
          #{Gen.GenEx.writeLog(state, "Started waiting.")}
          {:noreply, {nil, from}}
        end

        def handle_cast({:new_choice, choiceState}, {nil, nil}) do
          #{Gen.GenEx.writeLog(state, "got new state but client is not waiting yet")}
          {:noreply, {choiceState, nil}}
        end

        def handle_cast({:new_choice, choiceState}, {nil, from}) do
          #{Gen.GenEx.writeLog(state, "replying to wait")}
          GenServer.reply(from, choiceState)
          {:noreply, {nil, nil}}
        end
      """, else: "")}
    end
    """)
  end

  defp writeProcess(%Gen.GenState{} = state, p, choices) do
    s = %Gen.GenState{
      state
      | module_name: p.identifier,
        mcrl2_static_state: stateList(p),
        states_args: Map.new(p.states, fn %Commands.State{value: value, args: args} -> {value, args} end)
    }

    Gen.Helpers.writeLn(s, """
    defmodule #{p.identifier} do
      use GenServer
      require Logger

      def start_link(vars) do
        GenServer.start_link(__MODULE__, vars, name: __MODULE__)
      end

      def init(vars) do
        vars = %{#{stateInit(p)}}
        #{Gen.GenEx.writeLog(s, "initialised with \#{inspect(vars)}")}
        {:ok, vars}
      end

      def handle_cast(:start, state) do
        #{GenEx.writeCmds(s, p.init)}
        {:noreply, state}
      end

      #{Enum.map(choices, fn cmd ->
      [case1, case2] = cmd.body
      """
      def handle_cast({:#{cmd.label}, true}, state) do
          #{GenEx.writeCmds(s, [case1])}
          {:noreply, state}
        end

        def handle_cast({:#{cmd.label}, false}, state) do
          #{GenEx.writeCmds(s, [case2])}
          {:noreply, state}
        end
      """
      end)}

      #{GenEx.writeCmds(s, p.states)}

      defp updateState(state, new_map) do
        Enum.reduce(new_map, state, fn {k, v}, acc -> Map.put(acc, k, v) end)
      end

      defp var(state, key) do
        case Map.get(state, key) do
          nil -> raise "Key \#{inspect(key)} not found in state \#{inspect(state)}"
          x -> x
        end
      end
    end
    """)
  end

  def stateList(%__MODULE__{} = p), do: Keyword.keys(p.state)

  def stateStr(%__MODULE__{} = p) do
    Keyword.keys(p.state) |> Enum.join(", ")
  end

  def stateMap(%__MODULE__{} = p) do
    Keyword.keys(p.state) |> Enum.map(fn s -> ":#{s} => #{s}" end) |> Enum.join(", ")
  end

  def stateInit(%__MODULE__{} = p) do
    Keyword.keys(p.state) |> Enum.map(fn s -> ":#{s} => var(vars, :#{s})" end) |> Enum.join(", ")
  end

  def statePidNamesStr(%__MODULE__{} = p) do
    Keyword.values(p.state)
    |> Enum.map(fn {:pid, name} -> Gen.Helpers.pidName(name) end)
    |> Enum.join(", ")
  end
end
