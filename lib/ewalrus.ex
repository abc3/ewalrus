defmodule Ewalrus do
  @moduledoc """
  Documentation for `Ewalrus`.
  """

  @doc """
  Start db poller.

  ## Examples

      iex> Ewalrus.start_link()
      {:ok, pid}

  """
  def start_link() do
    {:ok, conn_pid} =
      Postgrex.start_link(database: "postgres", password: "postgres", username: "postgres")

    opts = [
      conn: conn_pid,
      backoff_type: :rand_exp,
      backoff_min: 100,
      backoff_max: 120_000,
      replication_poll_interval: 1000,
      publication: "supabase_realtime",
      slot_name: "supabase_realtime_replication_slot",
      max_record_bytes: 1_048_576
    ]

    {:ok, poll_pid} =
      DynamicSupervisor.start_child(Ewalrus.DynamicSupervisor, %{
        id: Ewalrus.ReplicationPoller,
        start: {Ewalrus.ReplicationPoller, :start_link, [opts]},
        restart: :transient
      })

    {:ok, conn_pid, poll_pid}
  end

  def stop(conn_pid, poll_pid) do
    GenServer.stop(poll_pid)
    GenServer.stop(conn_pid)
  end

  def create_topic_subscriber(conn) do
    params = dummy_params()
    Ewalrus.Subscriptions.create_topic_subscriber(conn, params)
  end

  def delete_subscriber(conn, id) do
    Ewalrus.Subscriptions.delete_topic_subscriber(conn, id)
  end

  def dummy_params() do
    %{
      claims: %{
        "aud" => "authenticated",
        "email" => "jwt@test.com",
        "exp" => 1_663_819_211,
        "iat" => 1_632_283_191,
        "iss" => "supabase",
        "role" => "authenticated",
        "sub" => "bbb51e4e-f371-4463-bf0a-af8f56dc9a73"
      },
      id: UUID.uuid1(),
      topic: "public"
    }
  end
end
