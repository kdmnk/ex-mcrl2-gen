defmodule User do
 def start(serverPid) do
  spawn(fn -> loop(serverPid) end)
 end
 defp loop(serverPid) do
  IO.puts("User: sending #{inspect(1)} to #{inspect(serverPid)}")
  send(serverPid, {self(), 1})
  receive do
   {^serverPid, v0} ->
    IO.puts("User: received #{inspect(v0)} from #{inspect(serverPid)}")
  end
  loop(serverPid)
 end
end
