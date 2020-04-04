defmodule Notifier.StatsServer do
  use GenServer

  @initial_state %{country_stats: %{}, district_stats: %{}, state_stats: %{}}

  @refresh_interval Application.fetch_env!(:notifier, :data_refresh_interval)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :load, 1000)
    {:ok, @initial_state}
  end

  def get_stats_for_country() do
    GenServer.call(__MODULE__, :country_stats)
  end

  def get_stats_for_district(pin_code) do
    GenServer.call(__MODULE__, {:district_stats, pin_code})
  end

  def get_stats_for_state(state) do
    GenServer.call(__MODULE__, {:state_stats, state})
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
    district = Task.async(Notifier.CsvProcessor, :process_district_file, [])
    state = Task.async(Notifier.CsvProcessor, :process_state_file, [])
    country = Task.async(Notifier.CsvProcessor, :process_country_file, [])
    {:ok, district_stats} = Task.await(district)
    {:ok, state_stats} = Task.await(state)
    {:ok, country_stats} = Task.await(country)

    data = Map.put(data, :district_stats, district_stats)
    data = Map.put(data, :state_stats, state_stats)
    data = Map.put(data, :country_stats, country_stats)

    Process.send_after(self(), :load, @refresh_interval)

    {:noreply, data}
  end
end
