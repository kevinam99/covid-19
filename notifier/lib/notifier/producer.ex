defmodule Notifier.Producer do
  use GenStage

  require Logger

  def start_link(opts) do
    GenStage.start_link(__MODULE__, [], opts)
  end

  def init(_args) do
    from_index = 0
    {:producer, from_index}
  end

  def handle_demand(demand, from_index) when demand > 0 do
    users = Notifier.DB.get_data(%{}, from_index, demand)

    case Enum.empty?(users) do
      false ->
        {:noreply, users, from_index + demand}

      true ->
        Logger.info("Received empty users. Shutting down pipeline")
        DynamicSupervisor.stop(Notifier.DynamicSupervisor)
        {:noreply, users, from_index + demand}
    end
  end
end

# Transform Genstage messages to the %Broadway.Message{} format
defmodule Notifier.MessageTransformer do
  def transform(user, _opts) do
    %Broadway.Message{
      data: user,
      acknowledger: {Notifier.MessageTransformer, :ack_id, user}
    }
  end

  def ack(_ref, _successes, _failures) do
    :ok
  end
end
