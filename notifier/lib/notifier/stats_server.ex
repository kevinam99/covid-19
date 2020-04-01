defmodule Notifier.StatsServer do
  use GenServer

  @initial_state %{country_stats: %{}, district_stats: %{}, state_stats: %{}}

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
    {:ok, district_stats} = Notifier.CsvProcessor.process_district_file()
    {:ok, state_stats} = Notifier.CsvProcessor.process_state_file()
    {:ok, country_stats} = Notifier.CsvProcessor.process_country_file()

    data = Map.put(data, :district_stats, district_stats)
    data = Map.put(data, :state_stats, state_stats)
    data = Map.put(data, :country_stats, country_stats)

    # DynamicSupervisor.start_child(Notifier.DynamicSupervisor, {Notifier.Pipeline, []})
    {:noreply, data}
  end
end
