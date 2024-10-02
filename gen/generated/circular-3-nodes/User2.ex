defmodule User2 do
 def start(nextPid) do
  spawn(fn -> loop(nextPid) end)
 end
 defp loop(nextPid) do
  receive do
   {user1, m} ->
    IO.puts("User2: received #{inspect(m)} from #{inspect(user1)}")
    IO.puts("User2: sending #{inspect(user1)} to #{inspect(nextPid)}")
    send(nextPid, {self(), user1})
  end
  loop(nextPid)
 end
end
