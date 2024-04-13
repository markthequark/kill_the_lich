defmodule Ship.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShipWeb.Telemetry,
      Ship.Repo,
      {DNSCluster, query: Application.get_env(:ship, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ship.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ship.Finch},
      # Start a worker by calling: Ship.Worker.start_link(arg)
      # {Ship.Worker, arg},
      # Start to serve requests, typically the last entry
      ShipWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ship.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShipWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
