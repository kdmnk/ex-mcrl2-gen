defmodule Main do
 def run() do
  IO.puts("Main: starting User1")
  user1_pid = User1.start()
  IO.puts("Main: User1 started with PID #{inspect(user1_pid)}")
  IO.puts("Main: starting User2")
  user2_pid = User2.start()
  IO.puts("Main: User2 started with PID #{inspect(user2_pid)}")
  IO.puts("Main: starting Mach")
  mach_pid = Mach.start(user1_pid, user2_pid)
  IO.puts("Main: Mach started with PID #{inspect(mach_pid)}")
 end
 def chooseAnswer(module, state) do
  #TODO: return value
  true
 end
 def chooseAnswer(module, state) do
  #TODO: return value
  true
 end
end
