import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :ship, Ship.Repo,
  username: "ship_phoenix",
  password: "phoenix",
  hostname: "localhost",
  database: "ship_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ship, ShipWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KvdTgnAdktX5mO6PcBAbaDwDkR+0BgI2ktCH0+E6zrL60vtwZGzt+nvQ+EJUGr/4",
  server: false

# In test we don't send emails.
config :ship, Ship.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
