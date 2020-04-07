defmodule Notifier.StatsServer do
  @moduledoc """
  Contains stats for country, state, district, refreshed every @refresh_interval
  """

  use GenServer

  @initial_state %{
    are_stats_good: false,
    country_stats: %{},
    district_stats: %{},
    state_stats: %{}
  }

  @refresh_interval Application.fetch_env!(:notifier, :data_refresh_interval)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :load, 1000)
    {:ok, @initial_state}
  end

  def are_stats_good? do
    GenServer.call(__MODULE__, :are_stats_good)
  end

  def set_stats_status do
    GenServer.call(__MODULE__, :set_stats_status)
  end

  def get_stats_for_country do
    GenServer.call(__MODULE__, :country_stats)
  end

  def get_stats_for_district(pin_code) do
    GenServer.call(__MODULE__, {:district_stats, pin_code})
  end

  def get_stats_for_state(state) do
    GenServer.call(__MODULE__, {:state_stats, state})
  end

  @impl true
  def handle_call(:are_stats_good, _from, data) do
    flag = data[:are_stats_good]

    {:reply, flag, data}
  end

  @impl true
  def handle_call({:set_stats_status, status}, _from, data) do
    data = Map.put(data, :are_stats_good, status)

    {:reply, status, data}
  end

  @impl true
  def handle_call(:country_stats, _from, data) do
    stats = data[:country_stats]

    {:reply, {:ok, stats}, data}
  end

  @impl true
  def handle_call({:district_stats, pin_code}, _from, data) do
    stats = data[:district_stats]

    {:reply, {:ok, stats[pin_code]}, data}
  end

  @impl true
  def handle_call({:state_stats, state}, _from, data) do
    stats = data[:state_stats]

    {:reply, {:ok, stats[state]}, data}
  end

  # Generate all the stats needed
  @impl true
  def handle_info(:load, data) do
    # mark state as bad so do not use
    data = Map.put(data, :are_stats_good, false)

    district = Task.async(Notifier.CsvProcessor, :process_district_file, [])
    state = Task.async(Notifier.CsvProcessor, :process_state_file, [])
    country = Task.async(Notifier.CsvProcessor, :process_country_file, [])
    {:ok, district_stats} = Task.await(district)
    {:ok, state_stats} = Task.await(state)
    {:ok, country_stats} = Task.await(country)

    data = Map.put(data, :district_stats, district_stats)
    data = Map.put(data, :state_stats, state_stats)
    data = Map.put(data, :country_stats, country_stats)

    # mark state as good so can use
    data = Map.put(data, :are_stats_good, true)

    Process.send_after(self(), :load, @refresh_interval)

    {:noreply, data}
  end
end
