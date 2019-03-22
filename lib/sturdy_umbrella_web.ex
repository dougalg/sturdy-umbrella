defmodule SturdyUmbrellaWeb do
  def view do
    quote do
      import Phoenix.LiveView, only: [live_render: 2, live_render: 3]
    end
  end

  def router do
    quote do
      import Phoenix.LiveView.Router
    end
  end
end
