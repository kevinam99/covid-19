import Config

state_map = %{
  "AP" => "Andhra Pradesh",
  "AR" => "Arunachal Pradesh",
  "AS" => "Assam",
  "BR" => "Bihar",
  "CG" => "Chhattisgarh",
  "GA" => "Goa",
  "GJ" => "Gujarat",
  "HR" => "Haryana",
  "HP" => "Himachal Pradesh",
  "JK" => "Jammu and Kashmir",
  "JH" => "Jharkhand",
  "KA" => "Karnataka",
  "KL" => "Kerala",
  "MP" => "Madhya Pradesh",
  "MH" => "Maharashtra",
  "MN" => "Manipur",
  "ML" => "Meghalaya",
  "MZ" => "Mizoram",
  "NL" => "Nagalan",
  "OR" => "Orissa",
  "PB" => "Punjab",
  "RJ" => "Rajasthan",
  "SK" => "Sikkim",
  "TN" => "Tamil Nadu",
  "UK" => "Uttarakhand",
  "UP" => "Uttar Pradesh",
  "WB" => "West Bengal",
  "TR" => "Tripura",
  "AN" => "Andaman and Nicobar Islands",
  "CH" => "Chandigarh",
  "DH" => "Dadra and Nagar Haveli",
  "DD" => "Daman and Diu",
  "DL" => "Delhi",
  "LD" => "Lakshadweep",
  "PY" => "Pondicherry"
}

config :notifier,
  data_refresh_interval: 1000 * 60 * 60,
  db_url: "mongodb://localhost:27017/covid",
  sms_auth_key: "HELLO WORLD",
  sms_url: "https://api.msg91.com/api/v2/sendsms",
  state_map: state_map

import_config "#{Mix.env()}.exs"
