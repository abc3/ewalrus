defmodule Ewalrus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {
        Ewalrus.ReplicationPoller,
        backoff_type: :rand_exp,
        backoff_min: 100,
        backoff_max: 120_000,
        replication_poll_interval: 1000,
        publication: "supabase_realtime",
        slot_name: "qwe1",
        max_record_bytes: 1_048_576
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ewalrus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
