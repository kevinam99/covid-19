defmodule DBTest do
  use ExUnit.Case

  alias Notifier.DB

  test "Fetches 20 items by default" do
    users = DB.get_data()
    assert Enum.count(users) == 20
  end

  test "Can limit how many users to fetch" do
    users = DB.get_data(%{}, 0, 10)
    assert Enum.count(users) == 10

    users = DB.get_data(%{}, 0, 12)
    assert Enum.count(users) == 12
  end

  test "Returns all if limit above max count" do
    users = DB.get_data(%{}, 0, 1000)
    assert Enum.count(users) == 200
  end
end
