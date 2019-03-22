defmodule SturdyUmbrellaWeb.ClockLive do
  use Phoenix.LiveView

  require Logger
  # Must be a number greater than or equal to 1
  #   Erlang only supports resolutions of 1ms or greater.
  @update_frequency 1

  # Called by `live_render` in our template
  def render(assigns) do
    ~L[<ol><%= for {page, count} <- @time do %>
       <li><%= page %> has <%= count %> views</li>
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
    assign(socket, :time, Enum.take(Enum.sort(:ets.tab2list(:page_cache), fn ({page1, count1}, {page2, count2}) -> count1 > count2 end), 100))
  end
end
