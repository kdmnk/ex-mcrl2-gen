defmodule Main do
  def run() do
    IO.puts("Main: starting User1")
    user1 = User1Api.init()
    IO.puts("Main: User1 started with PID #{inspect(user1.pid)}")
    IO.puts("Main: starting User2")
    user2 = User2Api.init()
    IO.puts("Main: User2 started with PID #{inspect(user2.pid)}")
    IO.puts("Main: starting Mach")
    mach = MachApi.init(user1.pid, user2.pid)
    IO.puts("Main: Mach started with PID #{inspect(mach.pid)}")

    MachApi.start(mach)

    User1Api.start(user1)
    User1Api.wait()
    |> User1Api.choosechooseAnswer(true)
    User2Api.start(user2)
    User2Api.wait()
    |> User2Api.choosechooseAnswer(false)
  end

end
