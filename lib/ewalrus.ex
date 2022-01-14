defmodule Ewalrus do
  require Logger

  alias Ewalrus.Registry.DbInstances
  alias Ewalrus.Registry.SubscriptionManagers
  alias Ewalrus.Registry.Subscribers
  alias Ewalrus.SubscriptionManager

  @moduledoc """
  Documentation for `Ewalrus`.
  """

  @doc """
  Start db poller.

  """
  @spec start(String.t(), String.t(), String.t(), String.t(), String.t()) ::
          :ok | {:error, :already_started}
  def start(id, host, name, user, pass) do
    case Registry.lookup(DbInstances, id) do
      [] ->
        opts = [id: id, db_host: host, db_name: name, db_user: user, db_pass: pass]

        DynamicSupervisor.start_child(Ewalrus.RlsSupervisor, %{
          id: id,
          start: {Ewalrus.DbSupervisor, :start_link, [opts]},
          restart: :transient
        })

      _ ->
        {:error, :already_started}
    end
  end

  def subscribe(name, subs_id, topic, claims) do
    pid = manager_pid(name)

    if pid do
      opts = %{
        topic: topic,
        id: subs_id,
        claims: claims
      }

      Registry.register(Subscribers, name, subs_id)
      SubscriptionManager.subscribe(pid, opts)
    end
  end

  def unsubscribe(name, subs_id) do
    pid = manager_pid(name)
    me = self()

    if pid do
      SubscriptionManager.unsubscribe(pid, subs_id)

      case Registry.lookup(Subscribers, name) do
        [{^me, ^subs_id}] ->
          stop(name)

        _ ->
          :ok
      end
    end
  end

  def stop(id) do
    case Registry.lookup(DbInstances, id) do
      [{pid, _}] ->
        Supervisor.stop(pid, :normal)

      _ ->
        :ok
    end
  end

  @spec manager_pid(any()) :: pid() | nil
  defp manager_pid(id) do
    case Registry.lookup(SubscriptionManagers, id) do
      [{pid, _}] ->
        pid

      _ ->
        nil
    end
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
