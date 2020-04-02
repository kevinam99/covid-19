defmodule Notifier.SMS do
  @api Application.fetch_env!(:notifier, :sms_url)
  @auth_key Application.fetch_env!(:notifier, :sms_auth_key)

  require Logger

  def send_sms(to, pin_code, state, country) do
    message = build_sms(pin_code, state, country)

    # remove +91 from phone number
    response = send_sms(String.slice(to, 3..13), message)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info("#{to} - #{message}")
        :ok

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        Logger.error("Error when sending sms to #{to}. Error: #{body}")
        {:error, body}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        Logger.error("Error when sending sms to #{to} with code #{code}. Error: #{body}")
        :error

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTPoison/Network error when sending sms to #{to} with reason #{reason}.")

        :error
    end

    :ok
  end

  defp build_sms(pin, state, country) do
    {:ok, country_stats} = Notifier.StatsServer.get_stats_for_country()
    {:ok, district_stats} = Notifier.StatsServer.get_stats_for_district(pin)
    {:ok, state_stats} = Notifier.StatsServer.get_stats_for_state(state)

    """
    Country: #{country}
    Deaths: #{country_stats[:deaths] || 0}
    Hospitalized: #{country_stats[:hospitalized] || 0}
    Recovered: #{country_stats[:recovered] || 0}
    State: #{state}
    Deaths: #{state_stats[:deaths] || 0}
    Hospitalized: #{state_stats[:hospitalized] || 0}
    Recovered: #{state_stats[:recovered] || 0}
    District: #{district_stats[:district] || 0}
    Deaths: #{district_stats[:deaths] || 0}
    Hospitalized: #{district_stats[:hospitalized] || 0}
    Recovered: #{district_stats[:recovered] || 0}
    Subscribe: bit.ly/coronadailyupdates
    """
  end

  defp send_sms(to, message) do
    data = %{
      sender: "SOCKET",
      route: "4",
      country: "IN",
      sms: [
        %{
          message: message,
          to: [to]
        }
      ]
    }

    headers = [{"content-type", "application/json"}, {"authkey", @auth_key}]
    HTTPoison.post(@api, Poison.encode!(data), headers)
  end
end
