defmodule Machine do
    def start() do
      spawn(fn -> loop() end)
    end

    defp loop() do
      receive do
        {from, 1} ->
          IO.puts("Machine: received 1 from #{inspect(from)}")
          send(from, {self(), 2})
      end
      loop()
    end
  end
