defmodule Gen.GenEx do
  alias Entities.Process
  require Logger

  def main(protocol) do
    <<first::utf8, rest::binary>> = String.split("#{protocol}", ".") |> List.last
    name = String.downcase(<<first::utf8>>) <> rest
    folder = "./generated/#{name}/lib/#{name}"
    if !File.exists?(folder) do
      Logger.info("Creating project in folder: #{folder}")
      System.cmd("mix", ["new", "./generated/#{name}", "--sup"])
      :ok = File.mkdir_p(folder)
    end

    conf = Conf.getConf(protocol)
    run(folder, conf)
  end

  def run(folder, %{:processes => processes, :messageType => messageType}) do
    for %Process{} = p <- processes do
      state = Gen.GenState.new("#{folder}/#{p.identifier}.ex")
      stateApi = Gen.GenState.new("#{folder}/#{p.identifier}Api.ex")

      Process.writeEx(state, stateApi, p, messageType)

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
    case ast do
      {op, _pos, [left, right]} when op in [:==, :!=, :>, :>=, :<=, :<, :-, :*, :+, :in, :/] -> "#{stringifyAST(left, getVarVals)} #{op} #{stringifyAST(right, getVarVals)}"
      [{op, _pos, [left, right]}] when op in [:==, :!=, :>, :>=, :<=, :<, :-, :*, :+, :in, :/] -> "(#{stringifyAST(left, getVarVals)} #{op} #{stringifyAST(right, getVarVals)})"
      [{:|, _pos, [left, right]}] -> "[#{stringifyAST(left, getVarVals)} | #{stringifyAST(right, getVarVals)}]"
      {:or, _pos, [left, right]} -> "(#{stringifyAST(left, getVarVals)} or #{stringifyAST(right, getVarVals)})"
      {:and, _pos, [left, right]} -> "(#{stringifyAST(left, getVarVals)} and #{stringifyAST(right, getVarVals)})"
      {:!, _pos, right} -> "!#{stringifyAST(right, getVarVals)}"
      {:length, _pos, arg} -> "length(#{stringifyAST(arg, getVarVals)})"
      {:ceil, _pos, arg} -> "Float.ceil(#{stringifyAST(arg, getVarVals)})"
      {:floor, _pos, arg} -> "Float.floor(#{stringifyAST(arg, getVarVals)})"
      {:self, _pos, _arg} -> "{__MODULE__, Node.self()}"
      {:index, _pos, [arg1, arg2]} -> "Enum.at(#{stringifyAST(arg1)}, #{stringifyAST(arg2)})"
      {:{}, _pos, arg} -> "{#{stringifyAST(arg)}}"
      {var, _pos, nil} -> stringifyAST(var, getVarVals)
      {atom, _pos, args} when is_atom(atom) -> "#{stringifyAST(args, getVarVals)}.#{atom}"
      tuple when is_tuple(tuple) -> "(#{Enum.map(Tuple.to_list(tuple), fn v -> stringifyAST(v, getVarVals) end) |> Enum.join(", ")})"
      boolean when boolean in ["true", :true, true, "false", :false, false] -> boolean
      int when is_integer(int) -> int
      var when is_atom(var) -> getVarVals.(var)
      [a | b] when b != [] -> "(#{stringifyAST(a, getVarVals)}, #{stringifyAST(b, getVarVals)})"
      [a] -> "(#{stringifyAST(a, getVarVals)})"
      [] -> "[]"
    end
  end
end
