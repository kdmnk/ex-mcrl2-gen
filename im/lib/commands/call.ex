defmodule Im.Commands.Call do
  defstruct [:name, :arg]

  def writeMcrl2(%Im.Gen.GenState{} = state, %Im.Commands.Call{} = cmd) do
    args = Enum.map(cmd.arg, fn x -> Im.Gen.GenMcrl2.stringifyAST(x) end)

    Im.Gen.Helpers.writeLn(state, "#{cmd.name}(pid, #{Enum.join(args, ", ")})")
  end

  def writeEx(%Im.Gen.GenState{} = state, %Im.Commands.Call{} = cmd) do
    args = Enum.map(cmd.arg, fn x ->
      x = GenEx.stringifyAST(x)
      if is_atom(x) do
        "Map.get(state, :#{x}, #{x})"
      else
        x
      end

    end)


    Im.Gen.Helpers.writeLn(state, "#{cmd.name}(state, #{Enum.join(args, ", ")})")
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
