defmodule User1 do
 def start() do
  spawn(fn -> loop() end)
 end
 defp loop() do
  receive do
   {server, m} when m == 0 ->
     IO.puts("User1: received #{inspect(m)} from #{inspect(server)} and 'm == 0' holds")
     if Main.chooseAnswer(__MODULE__, {}) do
      IO.puts("User1: sending #{inspect(1)} to #{inspect(server)}")
      send(server, {self(), 1})
     else
      IO.puts("User1: sending #{inspect(2)} to #{inspect(server)}")
      send(server, {self(), 2})
     end
   {server, m} when m == 3 ->
     IO.puts("User1: received #{inspect(m)} from #{inspect(server)} and 'm == 3' holds")
     IO.puts("User1: sending #{inspect(4)} to #{inspect(server)}")
     send(server, {self(), 4})
   {server, m} when m == 5 ->
     IO.puts("User1: received #{inspect(m)} from #{inspect(server)} and 'm == 5' holds")
     IO.puts("User1: sending #{inspect(4)} to #{inspect(server)}")
     send(server, {self(), 4})
  end
  loop()
 end
end
