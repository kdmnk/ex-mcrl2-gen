defmodule User do
 def start(serverPid) do
  spawn(fn -> loop(serverPid) end)
 end
 defp loop(serverPid) do
  IO.puts("User: sending #{1} to #{inspect(serverPid)}")
  send(serverPid, {self(), 1})
  receive do
   {^serverPid, v9} ->
    IO.puts("User: received #{v9} from #{inspect(serverPid)}")
  end
  loop(serverPid)
 end
end
