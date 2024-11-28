Path.wildcard("./generated/**/*.{ex,exs}")
|> Enum.filter(fn x -> x != "generated/compile.ex" end)
|> Enum.sort_by(&String.length/1, :desc) #xxxApi.ex first
|> Enum.each(fn file ->
  IO.puts("Compiling: #{file}")
  case Code.compile_file(file) do
    {:error, reason} ->
      IO.puts("Error compiling #{file}: #{reason}")
    _ ->
      IO.puts("Successfully compiled: #{file}")
  end
end)
