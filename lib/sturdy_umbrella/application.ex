defmodule SturdyUmbrella.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      SturdyUmbrellaWeb.PageCache,
      SturdyUmbrellaWeb.Endpoint,
      worker(Kaffe.Consumer, []) # calls to start Kaffe's Consumer module
    ]
    opts = [strategy: :one_for_one, name: SturdyUmbrellaWeb.PageCache.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SturdyUmbrellaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
