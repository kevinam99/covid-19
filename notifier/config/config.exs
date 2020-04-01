import Config

config :notifier,
  db_url: "mongodb://localhost:27017/covid",
  sms_auth_key: "HELLO WORLD",
  sms_url: "https://api.msg91.com/api/v2/sendsms"

import_config "#{Mix.env()}.exs"
