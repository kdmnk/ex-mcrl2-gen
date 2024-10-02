defmodule User3 do
 def start() do
  spawn(fn -> loop() end)
 end
 defp loop() do
  receive do
   {v2, m} ->
    IO.puts("User3: received #{inspect(m)} from #{inspect(v2)}")
    IO.puts("User3: sending #{inspect(2)} to #{inspect(m)}")
    send(m, {self(), 2})
  end
  loop()
 end
end
