defmodule Notifier.Http do
  use Plug.Router
  require Logger

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

  post "/admin/notifier" do
    admin_secret = Application.fetch_env!(:notifier, :admin_secret)

    validate_request = fn
      [secret: ^admin_secret, enable: flag] when is_boolean(flag) -> :ok
      _ -> :invalid
    end

    body = conn.params

    secret = body["secret"]
    enable = body["enable"]

    with :ok <- validate_request.(secret: secret, enable: enable),
         :ok = Notifier.set_enabled(enable) do
      response =
        Poison.encode!(%{
          message: "Success"
        })

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, response)
    else
      :invalid ->
        Logger.warn(
          "Got request to admin route with bad data. Secret: #{secret} - Enable: #{enable} "
        )

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Poison.encode!(%{error: "Bad data"}))
    end
  end

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Poison.encode!(%{error: "Not found"}))
  end
end
