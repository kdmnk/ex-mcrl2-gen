defmodule Main do
  def run() do
    IO.puts("Main: starting machine")
    machine_pid = Machine.start()
    IO.puts("Main: machine started with PID #{inspect(machine_pid)}")

    IO.puts("Main: starting user")
    user_pid = User.start(machine_pid)
    IO.puts("Main: user started with PID #{inspect(user_pid)}")
  end
end
