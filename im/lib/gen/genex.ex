defmodule Gen.GenEx do
  alias Processes.Process

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

  def run(folder, %{:processes => processes}) do
    for %Process{} = p <- processes do
      state = Gen.GenState.new("#{folder}/#{p.identifier}.ex")
      stateApi = Gen.GenState.new("#{folder}/#{p.identifier}Api.ex")

      Process.writeEx(state, stateApi, p)

      File.close(state.file)
      File.close(stateApi.file)

      System.cmd("mix", ["format", "#{folder}/#{p.identifier}.ex"])
      System.cmd("mix", ["format", "#{folder}/#{p.identifier}Api.ex"])


    end
  end

  def writeCmds(state, cmds) do
    Gen.Helpers.joinStr(fn cmd -> Commands.Command.writeEx(state, cmd) end, cmds)
  end

  def writeLog(%Gen.GenState{} = state, str) do
    stateLog = if(state.current_state !== nil, do: " [#{state.current_state}]", else: "")
    "Logger.info(\"#{state.module_name}#{stateLog}: #{str}\")"
  end

  def writeBlock(%Gen.GenState{} = state, str, child) do
    Gen.Helpers.writeLn(state, str)
    child.(Gen.GenState.indent(state))
    Gen.Helpers.writeLn(state, "end\n")
  end

  def stringifyASTwithLookup(ast) do
    stringifyAST(ast, fn x -> "var(state, :#{x})" end)
  end
  def stringifyAST(ast, getVarVals \\ fn x -> x end) do
    IO.inspect(ast)
    case ast do
      {op, _pos, [left, right]} when op in [:==, :>, :<, :-, :in] -> "#{stringifyAST(left, getVarVals)} #{op} #{stringifyAST(right, getVarVals)}"
      [{op, _pos, [left, right]}] when op in [:==, :>, :<, :-, :in] -> "(#{stringifyAST(left, getVarVals)} #{op} #{stringifyAST(right, getVarVals)})"
      [{:|, _pos, [left, right]}] -> "[#{stringifyAST(left, getVarVals)} | #{stringifyAST(right, getVarVals)}]"
      {:or, _pos, [left, right]} -> "(#{stringifyAST(left, getVarVals)} or #{stringifyAST(right, getVarVals)})"
      {:and, _pos, [left, right]} -> "(#{stringifyAST(left, getVarVals)} and #{stringifyAST(right, getVarVals)})"
      {:!, _pos, right} -> "!#{stringifyAST(right, getVarVals)}"
      {var, _pos, nil} -> stringifyAST(var, getVarVals)
      var when is_atom(var) -> getVarVals.(var)
      int when is_integer(int) -> int
      {:length, _pos, arg} -> "length(#{stringifyAST(arg, getVarVals)})"
      [a | b] when b != [] -> "(#{stringifyAST(a, getVarVals)}, #{stringifyAST(b, getVarVals)})"
      [a] -> "(#{stringifyAST(a, getVarVals)})"
      [] -> "[]"
    end
  end
end
