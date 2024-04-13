import Config

config :ship,
  ecto_repos: [Ship.Repo],
  generators: [timestamp_type: :utc_datetime]

config :ship, ShipWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ShipWeb.ErrorHTML, json: ShipWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ship.PubSub,
  live_view: [signing_salt: "wMIJtPd4"]

config :ship, Ship.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  ship: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  ship: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ecsx,
  tick_rate: 20,
  manager: Ship.Manager

import_config "#{config_env()}.exs"
