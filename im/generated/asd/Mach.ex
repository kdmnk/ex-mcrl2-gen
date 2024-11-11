defmodule Mach do
 def start(user1, user2) do
  spawn(fn -> loop(user1, user2) end)
 end
 defp loop(user1, user2) do
  IO.puts("Mach: sending #{inspect(0)} to #{inspect(user1)}")
  GenServer.cast(user1, {self(), 0})
  IO.puts("Mach: sending #{inspect(0)} to #{inspect(user2)}")
  GenServer.cast(user2, {self(), 0})
  receive do
   {some_user, m} ->
     IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)}")
  end
  receive do
    {some_user, m} ->
      IO.puts("Mach: received #{inspect(m)} from #{inspect(some_user)}")
  end
 end
end
