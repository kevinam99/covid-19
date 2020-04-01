defmodule Notifier.CsvProcessor do
  @district_file "lib/data.csv"
  @state_file "lib/state.csv"

  def process_district_file do
    district_data =
      File.stream!(@district_file)
      |> CSV.decode!(headers: true)
      |> Enum.reduce(%{}, fn
        stat, acc ->
          Map.put(
            acc,
            stat["Pincode"],
            new_pin_map(stat)
          )
      end)

    {:ok, district_data}
  end

  defp new_pin_map(stat) do
    %{
      :district => stat["District"],
      :deaths => stat["Deceased"],
      :hospitalized => stat["Hospitalized"],
      :recovered => stat["Recovered"]
    }
  end
end
