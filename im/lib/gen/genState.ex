defmodule Im.Gen.GenState do
  defstruct [:file, :indentation, :bounded_vars, :module_name, :module_state, :subprocesses]

  def new(filePath) do
    {:ok, file} = File.open(filePath, [:write])
    %Im.Gen.GenState{
      file: file,
      indentation: 0,
      bounded_vars: []
    }
  end

  def indent(%Im.Gen.GenState{} = state, value \\ 1) do
    %{state | indentation: state.indentation + value}
  end

  def addBoundVars(%Im.Gen.GenState{} = state, vars) do
    %{state | bounded_vars: state.bounded_vars ++ vars}
  end

end
