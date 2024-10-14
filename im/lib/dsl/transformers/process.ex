defmodule Im.DSL.Transformers.Process do

  def transform_run(entity) do
    run = Enum.map(entity.run, &transform_cmd/1)
    {:ok, %{entity | run: run}}
  end

  defp transform_cmd({:send, opts}), do:
    {:send, transform_message(opts)}
  defp transform_cmd({:receive, opts}), do:
    {:receive, transform_message(opts)}
  defp transform_cmd({:or, condName, conds}), do:
    {:or, condName, Enum.map(conds, &transform_cmd/1)}

  defp transform_message(opts) do
    opts
    |> Enum.map(fn
      {:message, msg} when is_binary(msg) ->
        {:message, parse_expression(msg)}

      other -> other
    end)
  end

  # Simple parser to transform "m+1" into {:addition, ["m", 1]}
  defp parse_expression(expr) do
    case String.split(expr, "+") do
      [lhs, rhs] -> {:addition, [String.trim(lhs), String.to_integer(rhs)]}
      _ -> expr
    end
  end

end
