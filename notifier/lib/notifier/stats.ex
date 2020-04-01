defmodule Notifier.Stats do
  def get_stats_for_country(country) do
    {:ok, [total: 2001, cured: 321, deaths: 27, new: 15, new_cured: 4, new_deaths: 1]}
  end

  def get_stats_for_state(state) do
    {:ok, [total: 80, cured: 9, deaths: 2, new: 3, new_cured: 1, new_deaths: 0]}
  end
end
