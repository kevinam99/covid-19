defmodule Notifier.CsvProcessor do
  @district_file "lib/district.csv"
  @state_file "lib/state.csv"

  def process_district_file do
    new_pin_map = fn stat ->
      %{
        district: stat["District"],
        deaths: stat["Deceased"],
        hospitalized: stat["Hospitalized"],
        recovered: stat["Recovered"]
      }
    end

    district_data =
      File.stream!(@district_file)
      |> CSV.decode!(headers: true)
      |> Enum.reduce(%{}, fn
        stat, acc ->
          Map.put(
            acc,
            stat["Pincode"],
            new_pin_map.(stat)
          )
      end)

    {:ok, district_data}
  end

  def process_state_file do
    new_state_map = fn stat ->
      %{
        deaths: stat["Deceased"],
        hospitalized: stat["Hospitalized"],
        recovered: stat["Recovered"]
      }
    end

    district_data =
      File.stream!(@state_file)
      |> CSV.decode!(headers: true)
      |> Enum.reduce(%{}, fn
        stat, acc ->
          Map.put(
            acc,
            stat["State"],
            new_state_map.(stat)
          )
      end)

    {:ok, district_data}
  end

  def process_country_file do
    add_state_stats = fn current, {_name, value} ->
      %{
        deaths: current[:deaths] + String.to_integer(value[:deaths]),
        hospitalized: current[:hospitalized] + String.to_integer(value[:hospitalized]),
        recovered: current[:recovered] + String.to_integer(value[:recovered])
      }
    end

    {:ok, state_stats} = process_state_file()

    country_stats = %{:deaths => 0, :hospitalized => 0, :recovered => 0}

    country_stats =
      state_stats
      |> Enum.reduce(country_stats, fn
        stat, acc ->
          add_state_stats.(acc, stat)
      end)

    {:ok, country_stats}
  end
end
