defmodule Ewalrus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :syn.add_node_to_scopes([Ewalrus.Subscribers])

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Ewalrus.RlsSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ewalrus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
