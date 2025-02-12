defmodule Entities.Process do
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

  def writeEx(%Gen.GenState{} = state, %Gen.GenState{} = stateApi, %__MODULE__{} = p, messageType) do
    choices = Gen.Helpers.getCommands(Commands.Choice, p.states ++ p.init)

    writeApi(stateApi, p, choices)
    writeProcess(state, p, choices, messageType)
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
      #{Enum.map(choices, fn cmd ->
      guard = case cmd.values do
          %Range{first: from, last: to} -> "when choice >= #{from} && choice <= #{to}"
          [l|ls] -> "when choice in [#{Enum.join([l|ls], ", ")}]"
          _ -> ""
      end
      """
      def choose#{Commands.Choice.getStateLabel(cmd)}(%Choice#{Commands.Choice.getStateLabel(cmd)}State{}, choice) #{guard} do
          GenServer.cast({#{p.identifier}, Node.self()}, {:#{cmd.name}, choice})
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

  defp writeProcess(%Gen.GenState{} = state, p, choices, messageType) do
    s = %Gen.GenState{
      state
      | module_name: p.identifier,
        #mcrl2_static_state: stateList(p),
        states_args: Map.new(p.states, fn %Entities.State{value: value, args: args} -> {value, args} end),
        struct_message_type: is_list(messageType)
    }

    structMessage = case messageType do
      keyword when is_list(keyword) ->
        """
        defmodule Message do
          defstruct [#{Keyword.keys(messageType) |> Enum.map(fn v -> ":#{v}" end) |> Enum.join(", ")}]

          def new(#{Keyword.keys(messageType) |> Enum.join(", ")}) do
            %Message{#{Keyword.keys(messageType) |> Enum.map(fn v -> "#{v}: #{v}" end) |> Enum.join(", ")}}
          end
        end
        """
      _ -> ""
    end

    Gen.Helpers.writeLn(s, """
    defmodule #{p.identifier} do
      use GenServer
      require Logger

      #{structMessage}

      def start_link(vars) do
        GenServer.start_link(__MODULE__, vars, name: __MODULE__)
      end

      def init(vars) do
        vars = %{#{stateInit(p)}}
        #{Gen.GenEx.writeLog(s, "initialised with \#{inspect(vars)}")}
        {:ok, vars}
      end

      def handle_cast(:start, state) do
        {:ok, timer} = :timer.apply_after(:rand.uniform(10000), fn () -> GenServer.cast(__MODULE__, :timeout) end)
        state = Map.put(state, :timer, timer)
        #{GenEx.writeCmds(s, p.init)}
        {:noreply, state}
      end

      #{Enum.map(choices, fn cmd ->
        """
        def handle_cast({:#{cmd.name}, #{cmd.name}}, state) do
            state = updateState(state, %{:#{cmd.name} => #{cmd.name}})
            #{GenEx.writeCmds(s, cmd.body)}
            {:noreply, state}
          end
        """
      end)}

      #{GenEx.writeCmds(s, p.states)}

      def handle_cast(:timeout, state) do
        #Logger.info(
        #  "Candidate [\#{state.state}]: timeout without effect"
        #)
        state = updateState(state, %{})
        {:noreply, state}
      end

      defp updateState(state, new_map) do
        :timer.cancel(var(state, :timer))
        {:ok, timer} = :timer.apply_after(:rand.uniform(10000), fn () -> GenServer.cast(__MODULE__, :timeout) end)
        state = %{state | timer: timer}
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
