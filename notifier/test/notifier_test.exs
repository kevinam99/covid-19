defmodule NotifierTest do
  use ExUnit.Case
  doctest Notifier

  test "greets the world" do
    assert Notifier.hello() == :world
  end
end
