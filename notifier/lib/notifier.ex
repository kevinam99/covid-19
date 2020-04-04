defmodule Notifier do
  use GenServer
  require Logger

  # hour of the day to send at in UTC time
  @time_to_send ~T[01:30:00]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_time_remaining(), do: GenServer.call(__MODULE__, :time_remaining)

  @impl true
  def init(:ok) do
    Process.send_after(self(), :schedule_notifier, 1000)
    # by default after a day
    timeout = 86400
    {:ok, timeout}
  end

  # set time for when notifier will be called next
  @impl true
  def handle_call(:time_remaining, _from, timeout) do
    {:reply, timeout, timeout}
  end

  # set time for when notifier will be called next
  @impl true
  def handle_info(:schedule_notifier, _timeout) do
    timeout = calc_time_remaining()
    Logger.info("Notifier scheduled in #{timeout / 1000} seconds")
    Process.send_after(self(), :start_notifier, timeout)
    {:noreply, timeout}
  end

  @impl true
  def handle_info(:start_notifier, timeout) do
    DynamicSupervisor.start_child(Notifier.DynamicSupervisor, {Notifier.Pipeline, []})

    Process.send_after(self(), :schedule_notifier, timeout)
    {:noreply, timeout}
  end

  def calc_time_remaining() do
    now = Time.utc_now()
    calc_seconds_remaining(now, @time_to_send) * 1000
  end

  defp calc_seconds_remaining(now, deadline) do
    # If not past deadline, return how long until deadline
    # If past deadline, see how much past deadline
    # 24 hours minus the time passed will give how much longer 

    cond do
      now.hour < deadline.hour ->
        Time.diff(deadline, now)

      true ->
        time_past = Time.diff(now, deadline)
        86400 - time_past
    end
  end
end
