defmodule Gen.GenEx do
  alias Processes.Process
  alias Processes.SubProcess

  def main() do
    name = "twoPhasedCommitMultiple"
    folder = "./generated/#{name}/lib"
    if !File.exists?(folder) do
      System.cmd("mix", ["new", name, "--sup"])
      :ok = File.mkdir_p(folder)
    end

    conf = Conf.getConf(Protocols.TwoPhasedCommitMultiple)
    run(folder, conf)
  end

  def run(folder, %{:processes => all_process}) do

    processes = Enum.filter(all_process, fn
      %Process{} -> true
     _ -> false
    end)

    for %Process{identifier: id} = p <- processes do
      state = Gen.GenState.new("#{folder}/#{p.identifier}.ex")
      stateApi = Gen.GenState.new("#{folder}/#{p.identifier}Api.ex")

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
  def writeCmds(state, [%Commands.Receive{} | _]) do
    Gen.Helpers.writeLn(state, "# Continues from a receive block...")
  end
  def writeCmds(state, [cmd | cmds]) do
    Commands.Command.writeEx(state, cmd)
    writeCmds(state, cmds)
  end

  def writeLog(%Gen.GenState{} = state, str, indentation \\ 0) do
    Gen.Helpers.writeLn(state, "Logger.info(\"#{state.module_name}: #{str}\")", indentation)
  end

  def writeBlock(%Gen.GenState{} = state, str, child) do
    Gen.Helpers.writeLn(state, str)
    child.(Gen.GenState.indent(state))
    Gen.Helpers.writeLn(state, "end\n")
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
      {:length, _pos, arg} -> "length(#{stringifyAST(arg, getVarVals)})"
      [a | b] when b != [] -> "(#{stringifyAST(a, getVarVals)}, #{stringifyAST(b, getVarVals)})"
      [a] -> "(#{stringifyAST(a, getVarVals)})"
      [] -> "[]"
    end
  end
end
