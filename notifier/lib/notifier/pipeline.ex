defmodule Notifier.Pipeline do
  use Broadway

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Notifier.Producer, [name: Notifier.Producer]},
        transformer: {Notifier.MessageTransformer, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 4]
      ]
    )
  end

  def handle_message(:default, %Broadway.Message{data: user} = message, _context) do
    :ok = Notifier.SMS.send_sms(user["phone"], user["pincode"], user["state"], user["country"])

    Process.sleep(3000)

    message
  end
end
