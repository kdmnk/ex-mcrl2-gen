defmodule Main do
 def run() do
  IO.puts("Main: starting User1")
  initState1 = User1.start()
  IO.puts("Main: User1 started with PID #{inspect(initState1.pid)}")
  IO.puts("Main: starting User2")
  initState2 = User2.start()
  IO.puts("Main: User2 started with PID #{inspect(initState2.pid)}")
  IO.puts("Main: starting Mach")
  mach_pid = Mach.start(initState1.pid, initState2.pid)
  IO.puts("Main: Mach started with PID #{inspect(mach_pid)}")

  state = User1.wait(initState1)
  IO.inspect(state)
  state = User1.chooseAnswer(state, false)
  IO.inspect(state)
  User2.wait(initState2)
  |> User2.chooseAnswer(true)
 end
end
