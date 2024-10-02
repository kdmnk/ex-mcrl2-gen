defmodule User1 do
 def start(nextPid) do
  spawn(fn -> loop(nextPid) end)
 end
 defp loop(nextPid) do
  IO.puts("User1: sending #{inspect(1)} to #{inspect(nextPid)}")
  send(nextPid, {self(), 1})
  receive do
   {v0, v1} ->
    IO.puts("User1: received #{inspect(v1)} from #{inspect(v0)}")
  end
  loop(nextPid)
 end
end
