defmodule Gen.GenState do
  defstruct [
    :file,
    :indentation, # for mcrl2 writing
    :module_name,
    :current_state, # for Ex
    :mcrl2_static_state, # pid and Process's main args
    :states_args, # list of all states and their args
    :struct_message_type # if the messageType is struct or not
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
