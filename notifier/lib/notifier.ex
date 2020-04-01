defmodule Notifier do
  alias Notifier.DB

  def get_data(skip \\ 0) do
    DB.get_data(%{}, skip)
  end
end
