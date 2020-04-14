defmodule NotifierTest do
  use ExUnit.Case
  doctest Notifier

  test "Calculates time remaining to run message service accurately" do
    # exactly at determined time, so send after 24 hours
    time = Time.utc_now()
    Application.put_env(:notifier, :notification_time, time)
    assert Notifier.calc_time_remaining() == 86_400_000

    # one hour before the set time, so send after 1 hour
    time = Time.utc_now() |> Time.add(3600)
    Application.put_env(:notifier, :notification_time, time)
    assert Notifier.calc_time_remaining() == 3_600_000

    # 10 seconds before the set time, so send after 10 seconds
    time = Time.utc_now() |> Time.add(10)
    Application.put_env(:notifier, :notification_time, time)
    assert Notifier.calc_time_remaining() == 10_000

    # one hour past the set time, so send after 23 hours
    time = Time.utc_now() |> Time.add(-3600)
    Application.put_env(:notifier, :notification_time, time)
    assert Notifier.calc_time_remaining() == 82_800_000
  end

  test "Can enable / disable message scheduling" do
    reply = GenServer.call(Notifier, {:set_enabled, false})
    assert reply[:enabled] == false

    reply = GenServer.call(Notifier, {:set_enabled, true})
    assert reply[:enabled] == true
  end
end
