defmodule Notifier.SMS do
  @api Application.fetch_env!(:notifier, :sms_url)
  @auth_key Application.fetch_env!(:notifier, :sms_auth_key)
  @state_map Application.fetch_env!(:notifier, :state_map)

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

  defp build_sms(pin, state, _country) do
    {:ok, country_stats} = Notifier.StatsServer.get_stats_for_country()
    {:ok, district_stats} = Notifier.StatsServer.get_stats_for_district(pin)
    {:ok, state_stats} = Notifier.StatsServer.get_stats_for_state(state)

    """
    *Coronavirus Numbers*
      ---India---
      Hospitalized: #{country_stats[:hospitalized] || 0}
      Deaths: #{country_stats[:deaths] || 0}

      ---#{@state_map[state] || state}---
      Hospitalized: #{state_stats[:hospitalized] || 0}
      Deaths: #{state_stats[:deaths] || 0}

      ---#{state_stats[:district] || 'District'}---
      Hospitalized: #{district_stats[:hospitalized] || 0}
      Deaths: #{district_stats[:deaths] || 0}
      
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
