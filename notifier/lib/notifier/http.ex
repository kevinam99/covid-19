defmodule Notifier.Http do
  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  post "/message" do
    body = conn.params

    to = body["phone"]
    pincode = body["pincode"]
    state = body["state"]
    country = body["country"]

    :ok = Notifier.SMS.send_welcome_sms(to, pincode, state, country)

    response =
      Poison.encode!(%{
        message: "Accepted message request to #{to}"
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Poison.encode!(%{error: "Not found"}))
  end
end
