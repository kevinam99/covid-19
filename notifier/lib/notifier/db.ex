defmodule Notifier.DB do
  @moduledoc """
  Connect to DB and execute operations
  """

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_data(filter \\ %{}, skip \\ 0, limit \\ 20) do
    GenServer.call(__MODULE__, {:query, filter, skip, limit})
  end

  @impl true
  def init(:ok) do
    db_url = Application.fetch_env!(:notifier, :db_url)
    {:ok, conn} = Mongo.start_link(url: db_url)
    {:ok, conn}
  end

  @impl true
  # limit 0 means no limit
  def handle_call({:query, filter, skip, limit}, _from, conn) do
    cursor = Mongo.find(conn, "users", filter, skip: skip, limit: limit)
    data = cursor |> Enum.to_list()

    {:reply, data, conn}
  end
end
