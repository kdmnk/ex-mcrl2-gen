defmodule User do
    def start(machine_pid) do
      spawn(fn -> loop(machine_pid) end)
    end

    defp loop(machine_pid) do
      IO.puts("User: sending 1 to machine with PID #{inspect(machine_pid)}")
      send(machine_pid, {self(), 1})

      receive do
        {^machine_pid, 2} ->
          IO.puts("User: received 2 from machine")
      end
      loop(machine_pid)
    end
  end
