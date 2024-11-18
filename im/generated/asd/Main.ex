defmodule Main do
  def run() do
    IO.puts("Main: starting User1")
    user1 = User1Api.init()
    IO.puts("Main: User1 started with PID #{inspect(user1.pid)}")
    IO.puts("Main: starting User2")
    user2 = User2Api.init()
    IO.puts("Main: User2 started with PID #{inspect(user2.pid)}")
    IO.puts("Main: starting Mach")
    mach_pid = MachApi.init(user1.pid, user2.pid)
    IO.puts("Main: Mach started with PID #{inspect(mach_pid.pid)}")

    MachApi.start()

    state = User1Api.wait(user1)
    state = User1Api.chooseAnswer(state, true)

    User2Api.wait(user2)
    |> User2Api.chooseAnswer(true)
 end

end
