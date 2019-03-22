use Mix.Config

config :my_app, MyAppWeb.Endpoint,
  live_view: [
    signing_salt: "AKdLfz0cijRvWTgQMgnBavbvvldnzAqS"
  ]

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
