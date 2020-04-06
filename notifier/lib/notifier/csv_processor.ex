defmodule Notifier.CsvProcessor do
  require Logger

  @file_urls [
    country: "https://coronadailyupdates.s3.ap-south-1.amazonaws.com/country_mohw",
    district: "https://coronadailyupdates.s3.ap-south-1.amazonaws.com/district_covid",
    state: "https://coronadailyupdates.s3.ap-south-1.amazonaws.com/state_mohw"
  ]

  def process_country_file do
    new_country_map = fn stats ->
      %{
        confirmed: stats["Confirmed"],
        deaths: stats["Deceased"]
      }
    end

    with {:ok, data} <- fetch_data(@file_urls[:country]) do
      country_data =
        data
        |> String.trim()
        |> String.split("\n")
        |> CSV.decode!(headers: true)
        |> Enum.map(&new_country_map.(&1))
        |> List.first()

      {:ok, country_data}
    else
      err -> err
    end
  end

  def process_district_file do
    new_pin_map = fn stat ->
      %{
        confirmed: stat["Confirmed"],
        district: stat["District"]
      }
    end

    with {:ok, data} <- fetch_data(@file_urls[:district]) do
      district_data =
        data
        |> String.trim()
        |> String.split("\n")
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
    else
      err -> err
    end
  end

  def process_state_file do
    new_state_map = fn stat ->
      %{
        confirmed: stat["Confirmed"],
        deaths: stat["Deceased"]
      }
    end

    with {:ok, data} <- fetch_data(@file_urls[:state]) do
      state_data =
        data
        |> String.trim()
        |> String.split("\n")
        |> CSV.decode!(headers: true)
        |> Enum.reduce(%{}, fn
          stat, acc ->
            Map.put(
              acc,
              stat["State"],
              new_state_map.(stat)
            )
        end)

      {:ok, state_data}
    else
      err -> err
    end
  end

  defp fetch_data(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url) do
      {:ok, body}
    else
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Logger.error("Error when fetching state file with code #{code}. Error: #{body}")
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison/Network error when fetching state file with reason #{reason}.")
        {:error, reason}
    end
  end
end
