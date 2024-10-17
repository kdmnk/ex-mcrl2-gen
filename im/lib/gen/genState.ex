defmodule Im.Gen.GenState do
  defstruct [:file, :indentation, :bounded_vars]

  def new(filePath) do
    {:ok, file} = File.open(filePath, [:write])
    %Im.Gen.GenState{
      file: file,
      indentation: 0,
      bounded_vars: []
    }
  end
end
