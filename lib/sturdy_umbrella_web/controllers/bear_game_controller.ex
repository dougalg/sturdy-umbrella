defmodule SturdyUmbrellaWeb.BearGameController do
  use SturdyUmbrellaWeb, :controller
  alias Phoenix.LiveView
  alias SturdyUmbrellaWeb.BearGameLive

  def index(conn, params) do
    LiveView.Controller.live_render(conn, BearGameLive, session: %{})
  end
end
