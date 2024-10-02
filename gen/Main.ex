defmodule Main do
 def run() do
  IO.puts("Main: starting Mach")
  mach_pid = Mach.start()
  IO.puts("Main: Mach started with PID #{inspect(mach_pid)}")
  IO.puts("Main: starting User")
  user_pid = User.start(mach_pid)
  IO.puts("Main: User started with PID #{inspect(user_pid)}")
 end
end
