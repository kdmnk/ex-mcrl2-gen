defmodule Mach do
 def start(user1, user2) do
  spawn(fn -> loop(user1, user2) end)
 end
 defp loop(user1, user2) do
  IO.puts("Mach: sending #{inspect(0)} to #{inspect(user1)}")
  send(user1, {self(), 0})
  IO.puts("Mach: sending #{inspect(0)} to #{inspect(user2)}")
  send(user2, {self(), 0})
  receive do
   {some_user, m} when m == 1 ->
     IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 1' holds")
     IO.puts("Mach: sending #{inspect(3)} to #{inspect(user1)}")
     send(user1, {self(), 3})
     IO.puts("Mach: sending #{inspect(3)} to #{inspect(user2)}")
     send(user2, {self(), 3})
   {some_user, m} when m == 2 ->
     IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'm == 2' holds")
     IO.puts("Mach: sending #{inspect(5)} to #{inspect(user1)}")
     send(user1, {self(), 5})
     IO.puts("Mach: sending #{inspect(5)} to #{inspect(user2)}")
     send(user2, {self(), 5})
  end
  receive do
   {some_user, m} when true ->
     IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)} and 'true' holds")
  end
  loop(user1, user2)
 end
end
