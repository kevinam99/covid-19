defmodule Notifier.CsvProcessor do
  require Logger

  @file_urls [
    state: "https://coronadailyupdates.s3.ap-south-1.amazonaws.com/state",
    district: "https://coronadailyupdates.s3.ap-south-1.amazonaws.com/district"
  ]

  def process_district_file do
    new_pin_map = fn stat ->
      %{
        district: stat["District"],
        deaths: stat["Deceased"],
        hospitalized: stat["Hospitalized"],
        recovered: stat["Recovered"]
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
        deaths: stat["Deceased"],
        hospitalized: stat["Hospitalized"],
        recovered: stat["Recovered"]
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
