defmodule SturdyUmbrellaWeb.PageController do
  use SturdyUmbrellaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
