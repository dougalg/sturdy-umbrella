defmodule SturdyUmbrellaWeb.Router do
  use SturdyUmbrellaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SturdyUmbrella do
    pipe_through :browser

    get "/", PageController, :index
  end
end
