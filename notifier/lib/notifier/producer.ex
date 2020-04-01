defmodule Notifier.Producer do
  use GenStage

  def start_link(opts) do
    GenStage.start_link(__MODULE__, [], opts)
  end

  def init(_args) do
    from_index = 0
    {:producer, from_index}
  end

  def handle_demand(demand, from_index) when demand > 0 do
    users = Notifier.DB.get_data(%{}, from_index, demand)

    {:noreply, users, from_index + demand - 1}
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
