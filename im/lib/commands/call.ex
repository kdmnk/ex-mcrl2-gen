defmodule Im.Commands.Call do
  defstruct [:name, :arg]

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Call{} = cmd) do
    args = Keyword.keys(state.module_state) ++ Enum.map(cmd.arg, fn x -> Im.Gen.GenMcrl2.stringifyAST(x) end)

    Im.Gen.Helpers.writeLn(state, "#{cmd.name}(#{Enum.join(args, ", ")})")
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Call{} = cmd) do
    argNames = state.subprocesses[cmd.name]
    argVals = Enum.map(cmd.arg, fn x -> GenEx.stringifyAST(x, true) end)
    args = Enum.zip(argNames, argVals) |> Enum.map(fn {x, y} -> ":#{x} => #{y}" end)
    Im.Gen.Helpers.writeLn(state, "state = updateState(state, %{#{Enum.join(args, ", ")}})")
    Im.Gen.Helpers.writeLn(state, "state = #{cmd.name}(state)")
  end

  # def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Receive{} = cmd) do
  #   {newState, newCmd} = boundNewVariables(state, cmd)

  #   caseString = fn (condition) ->
  #     Im.Gen.Helpers.writeLn(state, buildCmdString(state, newCmd, condition))
  #   end

  #   Im.Gen.Helpers.join(
  #     state,
  #     fn (caseCmd) ->
  #       caseString.(Im.Commands.IfCond.stringifyAST(caseCmd.condition))
  #       Im.Gen.GenMcrl2.writeCmds(%{newState | indentation: state.indentation+1}, caseCmd.body)
  #     end,
  #     cmd.body,
  #     "+"
  #   )

  # end

end
