defmodule Main do
 def run() do
  IO.puts("Main: starting User3")
  user3_pid = User3.start()
  IO.puts("Main: User3 started with PID #{inspect(user3_pid)}")
  IO.puts("Main: starting User2")
  user2_pid = User2.start(user3_pid)
  IO.puts("Main: User2 started with PID #{inspect(user2_pid)}")
  IO.puts("Main: starting User1")
  user1_pid = User1.start(user2_pid)
  IO.puts("Main: User1 started with PID #{inspect(user1_pid)}")
 end
end
