defmodule Addition.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ClientApi, []},
      {Client, %{:server => {Server, :"server@127.0.0.1"}}},
      {Server, []},
      {ServerApi,[]},
      {Cluster.Supervisor, [topologies(), [name: ClusterSupervisor]]},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Addition.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
    [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"client@127.0.0.1",
            :"server@127.0.0.1",
          ]
        ]
      ]
    ]
  end
end
