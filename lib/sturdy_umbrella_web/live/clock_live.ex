defmodule SturdyUmbrellaWeb.ClockLive do
  use Phoenix.LiveView

  require Logger
  # Must be a number greater than or equal to 1
  #   Erlang only supports resolutions of 1ms or greater.
  @update_frequency 1
  @total_rotations 12

  # Called by `live_render` in our template
  def render(assigns) do
    ~L[
      <ol class="page-list">
      <%= for {page, count, title, url, img, roller_img, time, rank} <- @time do %>
        <li
          class="page-item"
        >
          <%= rank + 1 %>
          <a href="<%= url %>">
            <%= title %>
          </a>
          <div class="page-content">
            <div class="page-meta">
              <p>
                <%= count %> views
              </p>
              <div class="page-image-container">
                <img class="page-image" src="<%= img %>"/>
              </div>
            </div>
            <img
              class="rolling-image"
              src="<%= roller_img %>"
              style="transform: translateX(<%= rem(div(count, 10) * 20, 800) %>px) rotate(<%= Kernel.trunc(div(count, 10) * 20 * 1.5) %>deg);"
            />
          </div>
        </li>
      <% end %>
      </ol>
    ]
  end

  def count_changed(thing) do
    send self(), {:update}
  end

  # Runs once, on page load
  def mount(_session, socket) do
    if connected?(socket) do
      :timer.send_interval(@update_frequency, self(), :update)
    end

    {:ok, update_time(socket)}
  end

  def handle_info(:update, socket) do
    {:noreply, update_time(socket)}
  end

  defp update_time(socket) do
    idx = 0;
    vals = Enum.sort(:ets.tab2list(:page_cache), fn (a, b) -> Kernel.elem(a, 1) > Kernel.elem(b, 1) end)
      |> Enum.take(10)
      |> Enum.with_index
      |> Enum.map(fn ({ values, i }) -> Tuple.append(values, i) end)
    assign(socket, :time, vals)
  end
end
