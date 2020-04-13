defmodule Notifier.SMS do
  @moduledoc """
  Logic to build and send sms based on passed in subscriber details
  """

  @api Application.fetch_env!(:notifier, :sms_url)
  @auth_key Application.fetch_env!(:notifier, :sms_auth_key)
  @state_map Application.fetch_env!(:notifier, :state_map)

  require Logger

  def send_stat_sms(to, pin_code, state, country) do
    message = build_sms(pin_code, state, country)

    # remove +91 from phone number
    send_sms(String.slice(to, 3..13), message)
    |> handle_sms_response(to, message)

    :ok
  end

  def send_welcome_sms(to, pin_code, state, country) do
    message = """
    Thank you for subscribing!

    #{build_sms(pin_code, state, country)}
    """

    # remove +91 from phone number
    send_sms(String.slice(to, 3..13), message)
    |> handle_sms_response(to, message)

    :ok
  end

  defp build_sms(pin, state, _country) do
    {:ok, country_stats} = Notifier.StatsServer.get_stats_for_country()
    {:ok, district_stats} = Notifier.StatsServer.get_stats_for_district(pin)
    {:ok, state_stats} = Notifier.StatsServer.get_stats_for_state(state)

    """
    *Coronavirus Numbers*
      ---India---
      Total: #{country_stats[:total] || 0}
      Current: #{country_stats[:current] || 0}
      Deaths: #{country_stats[:deaths] || 0}

      ---#{@state_map[state] || state}---
      Total: #{state_stats[:total] || 0}
      Current: #{state_stats[:current] || 0}
      Deaths: #{state_stats[:deaths] || 0}

      ---#{district_stats[:district] || 'District'}---
      Total: #{district_stats[:total] || 0}

      Subscribe: bit.ly/coronadailyupdates
    """
  end

  defp send_sms(to, message) do
    data = %{
      sender: "CORONA",
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

  defp handle_sms_response(response, to, message) do
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
  end
end
