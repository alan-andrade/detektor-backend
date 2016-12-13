# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :detektor, Detektor.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lHFfgswLNk0QWvnt/EZs8D3Mvi5VrvR4PR6NzFVkO8Z2M090BkJbcy+h/jjM0VjV",
  render_errors: [view: Detektor.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Detektor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
