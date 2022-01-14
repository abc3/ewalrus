defmodule Ewalrus.DbSupervisor do
  # Automatically defines child_spec/1
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    {:ok, conn} =
      Postgrex.start_link(
        hostname: args[:db_host],
        database: args[:db_name],
        password: args[:db_pass],
        username: args[:db_user]
      )

    Registry.register(
      Ewalrus.Registry.DbInstances,
      args[:id],
      {conn, System.system_time(:second)}
    )

    opts = [
      id: args[:id],
      conn: conn,
      backoff_type: :rand_exp,
      backoff_min: 100,
      backoff_max: 120_000,
      replication_poll_interval: 1000,
      publication: "supabase_realtime",
      slot_name: "supabase_realtime_replication_slot",
      max_record_bytes: 1_048_576
    ]

    children = [
      %{
        id: Ewalrus.ReplicationPoller,
        start: {Ewalrus.ReplicationPoller, :start_link, [opts]},
        restart: :transient
      },
      %{
        id: Ewalrus.SubscriptionManager,
        start: {Ewalrus.SubscriptionManager, :start_link, [%{conn: conn, id: args[:id]}]},
        restart: :transient
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
