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

    case fetch_data(@file_urls[:country]) do
      {:ok, data} ->
        country_data =
          data
          |> String.trim()
          |> String.split("\n")
          |> CSV.decode!(headers: true)
          |> Enum.map(&new_country_map.(&1))
          |> List.first()

        {:ok, country_data}

      err ->
        err
    end
  end

  def process_district_file do
    new_pin_map = fn stat ->
      %{
        confirmed: stat["Confirmed"],
        district: stat["District"]
      }
    end

    case fetch_data(@file_urls[:district]) do
      {:ok, data} ->
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

      err ->
        err
    end
  end

  def process_state_file do
    new_state_map = fn stat ->
      %{
        confirmed: stat["Confirmed"],
        deaths: stat["Deceased"]
      }
    end

    case fetch_data(@file_urls[:state]) do
      {:ok, data} ->
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

      err ->
        err
    end
  end

  defp fetch_data(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Logger.error("Error when fetching state file with code #{code}. Error: #{body}")
        {:error, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison/Network error when fetching state file with reason #{reason}.")
        {:error, reason}
    end
  end
end
