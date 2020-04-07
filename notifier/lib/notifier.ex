defmodule Notifier do
  use GenServer
  require Logger

  # hour of the day to send at in UTC time
  @time_to_send ~T[01:30:00]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :schedule_notifier, 1000)
    # by default after a day
    state = [timeout: 86400, enabled: true]
    {:ok, state}
  end

  def set_enabled(flag) do
    GenServer.call(__MODULE__, {:set_enabled, flag})
    Logger.info("Set Notifier enabled flag to #{flag}")
    :ok
  end

  @impl true
  def handle_call({:set_enabled, true}, _from, state) do
    state = Keyword.put(state, :enabled, true)
    {:reply, state, state}
  end

  @impl true
  def handle_call({:set_enabled, false}, _from, state) do
    state = Keyword.put(state, :enabled, false)
    {:reply, state, state}
  end

  # set time for when notifier will be called next
  @impl true
  def handle_info(:schedule_notifier, state) do
    timeout = calc_time_remaining()
    Logger.info("Notifier scheduled in #{timeout / 1000} seconds")
    Process.send_after(self(), :start_notifier, timeout)

    state = Keyword.put(state, :timeout, timeout)

    {:noreply, state}
  end

  # if enabled, send messages and schedule for next day
  # if disabled, check again in an hour
  @impl true
  def handle_info(:start_notifier, state) do
    stats_status = Notifier.StatsServer.are_stats_good?()

    case state[:enabled] and stats_status do
      true ->
        DynamicSupervisor.start_child(Notifier.DynamicSupervisor, {Notifier.Pipeline, []})
        # schedule for the next day immediately
        Process.send_after(self(), :schedule_notifier, 0)
        {:noreply, state}

      false ->
        timeout = 1000 * 60 * 60
        Logger.info("Notifier disabled. Trying again in #{timeout / 1000} seconds")
        Process.send_after(self(), :start_notifier, timeout)
        state = Keyword.put(state, :timeout, timeout)
        {:noreply, state}
    end
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
      Time.diff(now, deadline) < 0 ->
        Time.diff(deadline, now)

      true ->
        time_past = Time.diff(now, deadline)
        86400 - time_past
    end
  end
end
