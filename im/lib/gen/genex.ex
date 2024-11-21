defmodule GenEx do
  alias Im.SubProcess
  alias Im.Process
  def main() do
    folder = "./generated/asd"
    :ok = File.mkdir_p(folder)

    conf = Conf.getConf()["asd"]
    run(folder, conf)
  end

  def run(folder, %{:processes => all_process}) do

    processes = Enum.filter(all_process, fn
      %Process{} -> true
     _ -> false
    end)

    for %Process{identifier: id} = p <- processes do
      state = Im.Gen.GenState.new("#{folder}/#{p.identifier}.ex")
      stateApi = Im.Gen.GenState.new("#{folder}/#{p.identifier}Api.ex")

      subprocesses = Enum.filter(all_process, fn
        %SubProcess{process: ^id} -> true
        _ -> false
      end)

      subprocInfo = Enum.map(subprocesses, fn
        %SubProcess{name: name} = p -> {name, SubProcess.stateList(p)}
      end)
      |> Map.new()
      state = %{state | subprocesses: subprocInfo}

      Process.writeEx(state, stateApi, p, subprocesses)

      File.close(state.file)
    end
  end

  def writeCmds(_, []), do: IO.puts("")
  def writeCmds(state, [%Im.Commands.Receive{} | _]) do
    Im.Gen.Helpers.writeLn(state, "# Continues from a receive block...")
  end
  def writeCmds(state, [cmd | cmds]) do
    Im.Commands.writeEx(state, cmd)
    writeCmds(state, cmds)
  end

  def writeLog(%Im.Gen.GenState{} = state, str, indentation \\ 0) do
    Im.Gen.Helpers.writeLn(state, "IO.puts(\"#{state.module_name}: #{str}\")", indentation)
  end

  def writeBlock(%Im.Gen.GenState{} = state, str, child) do
    Im.Gen.Helpers.writeLn(state, str)
    child.(Im.Gen.GenState.indent(state))
    Im.Gen.Helpers.writeLn(state, "end\n")
  end

  def stringifyAST(ast, getVarVals \\ false) do
    case ast do
      {op, _pos, [left, right]} when op in [:==, :>, :<, :-, :in] -> "#{stringifyAST(left, getVarVals)} #{op} #{stringifyAST(right, getVarVals)}"
      [{op, _pos, [left, right]}] when op in [:==, :>, :<, :-, :in] -> "(#{stringifyAST(left, getVarVals)} #{op} #{stringifyAST(right, getVarVals)})"
      [{:|, _pos, [left, right]}] -> "[#{stringifyAST(left, getVarVals)} | #{stringifyAST(right, getVarVals)}]"
      {:or, _pos, [left, right]} -> "#{stringifyAST(left, getVarVals)} or #{stringifyAST(right, getVarVals)}"
      {:and, _pos, [left, right]} -> "#{stringifyAST(left, getVarVals)} and #{stringifyAST(right, getVarVals)}"
      {:!, _pos, right} -> "!#{stringifyAST(right, getVarVals)}"
      {var, _pos, nil} -> stringifyAST(var, getVarVals)
      var when is_atom(var) -> if(getVarVals, do: "var(state, :#{var})", else: var)
      int when is_integer(int) -> int
      [] -> "[]"
    end
  end
end
