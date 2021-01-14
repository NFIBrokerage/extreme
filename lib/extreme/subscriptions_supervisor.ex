defmodule Extreme.SubscriptionsSupervisor do
  use DynamicSupervisor
  alias Extreme.{Subscription, ReadingSubscription}

  require Logger

  def _name(base_name),
    do: Module.concat(base_name, SubscriptionsSupervisor)

  def start_link(base_name),
    do: DynamicSupervisor.start_link(__MODULE__, :ok, name: _name(base_name))

  def init(:ok) do
    # connection_pid =
    #   Process.whereis(FreightBillAudit.ExStreamDomainEventStoreClient.Connection)
    #   |> IO.inspect(label: "found connection pid")
    #
    # connection_ref =
    #   Process.monitor(connection_pid) |> IO.inspect(label: "SubSup's connection monitor ref")

    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_subscription(
        base_name,
        correlation_id,
        subscriber,
        stream,
        resolve_link_tos,
        ack_timeout \\ 5_000
      ) do
    base_name
    |> _name()
    |> DynamicSupervisor.start_child(%{
      id: Subscription,
      start:
        {Subscription, :start_link,
         [base_name, correlation_id, subscriber, stream, resolve_link_tos, ack_timeout]},
      restart: :temporary
    })
  end

  def start_subscription(base_name, correlation_id, subscriber, read_params) do
    base_name
    |> _name()
    |> DynamicSupervisor.start_child(%{
      id: ReadingSubscription,
      start:
        {ReadingSubscription, :start_link, [base_name, correlation_id, subscriber, read_params]},
      restart: :temporary
    })
  end

  # def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
  #   Logger.warn(
  #     "#{__MODULE__}: Received DOWN message from #{inspect(ref)} because #{inspect(reason)}"
  #   )
  #
  #   {:stop, :connection_closed, state}
  # end
end
