defmodule SturdyUmbrellaWeb.PageController do
  use SturdyUmbrellaWeb, :controller
  alias Phoenix.LiveView
  alias SturdyUmbrellaWeb.ClockLive

  def index(conn, _params) do
    # render(conn, "index.html")
    LiveView.Controller.live_render(conn, ClockLive, session: %{})
  end
end
