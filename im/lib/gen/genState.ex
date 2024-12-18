defmodule Gen.GenState do
  defstruct [
    :file,
    :indentation,
    :module_name,
    :current_state,
    :mcrl2_static_state,
    :states_args
  ]

  def new(filePath) do
    {:ok, file} = File.open(filePath, [:write])
    %Gen.GenState{
      file: file,
      indentation: 0,
    }
  end

  def indent(%Gen.GenState{} = state, value \\ 1) do
    %{state | indentation: state.indentation + value}
  end

end
