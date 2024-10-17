defmodule Im.Commands.IfCond do
  defstruct [:condition, :body]


  def writeMcrl2(%Im.Commands.IfCond{} = cmd, %Im.Gen.GenState{} = state) do
    Im.Gen.Helpers.writeLn(state, "some condition -> (")

    Enum.map(cmd.body, fn (cmd) ->
      Im.Commands.writeMcrl2(cmd, %{state | indentation: state.indentation+1})
    end)
    Im.Gen.Helpers.writeLn(state, ")")
  end
end
