defmodule Mach do
 def start() do
  spawn(fn -> loop() end)
 end
 defp loop() do
  receive do
   {p, m} ->
    IO.puts("Mach: received #{m} from #{inspect(p)}")
    IO.puts("Mach: sending #{m+1} to #{inspect(p)}")
    send(p, {self(), m+1})
  end
  loop()
 end
end
