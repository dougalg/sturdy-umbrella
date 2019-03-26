# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :sturdy_umbrella, SturdyUmbrellaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GDMQPLUkLSPoqUT8vaimRrwv6oFFFWn3ooE/g9fd6aU95V3yeTBabNCj4zc70MkZ",
  render_errors: [view: SturdyUmbrellaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SturdyUmbrella.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "gqKkGatgzyF+N1umutKWxm5fuaAKDFDR"]

# Configures Elixir's Logger
config :logger, :console,
  level: :warn,
  format: "$time $metadata[$level] $message\n",
  compile_time_purge_matching: [
    [application: :kaffe],
  ],
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# config :kaffe,
#   producer: [
#     endpoints: ['ec2-34-224-29-58.compute-1.amazonaws.com': 9092],
#     # endpoints references [hostname: port]. Kafka is configured to run on port 9092.
#     # In this example, the hostname is localhost because we've started the Kafka server
#     # straight from our machine. However, if the server is dockerized, the hostname will
#     # be called whatever is specified by that container (usually "kafka")
#     topics: ["ingest-tracking-events"], # add a list of topics you plan to produce messages to
#   ]

config :kaffe,
  consumer: [
    endpoints:  ['10.3.36.186': 9092],
    # endpoints:  ['main.kafka.viafoura.net': 9092],
    topics: ["ingest-tracking-events"],     # the topic(s) that will be consumed
    consumer_group: "mrco3-group",   # the consumer group for tracking offsets in Kafka
    message_handler: SturdyUmbrellaWeb.KafkaConsumer,           # the module that will process messages
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
