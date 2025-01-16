defmodule Raftunlimited.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {CandidateApi, []},
      {Candidate, %{:others => [
        {Candidate, :"candidate1@127.0.0.1"},
        {Candidate, :"candidate2@127.0.0.1"},
        {Candidate, :"candidate3@127.0.0.1"},
        {Candidate, :"candidate4@127.0.0.1"},
        {Candidate, :"candidate5@127.0.0.1"},
      ]}},
      {Cluster.Supervisor, [topologies(), [name: ClusterSupervisor]]},
      # Starts a worker by calling: Raftunlimited.Worker.start_link(arg)
      # {Raftunlimited.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Raftunlimited.Supervisor]
    Supervisor.start_link(children, opts)
end

  defp topologies do
    [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [
          hosts: [
            :"candidate1@127.0.0.1",
            :"candidate2@127.0.0.1",
            :"candidate3@127.0.0.1",
            :"candidate4@127.0.0.1",
            :"candidate5@127.0.0.1",
          ]
        ]
      ]
    ]
  end
end
