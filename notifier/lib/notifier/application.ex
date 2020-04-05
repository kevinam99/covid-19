defmodule Notifier.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Notifier, []},
      {Notifier.StatsServer, []},
      {Plug.Cowboy, scheme: :http, plug: Notifier.Http, options: [port: 8000]},
      {DynamicSupervisor, strategy: :one_for_one, name: Notifier.DynamicSupervisor},
      {Notifier.DB, []}
    ]

    opts = [strategy: :one_for_one, name: Notifier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
