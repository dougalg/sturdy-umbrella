defmodule SturdyUmbrellaWeb.ClockLive do
  use Phoenix.LiveView

  require Logger
  # Must be a number greater than or equal to 1
  #   Erlang only supports resolutions of 1ms or greater.
  @update_frequency 100
  @roller_img_urls [
    "https://viafoura.com/wp-content/uploads/Jesse-1.png",
    "https://viafoura.com/wp-content/uploads/Ray-1.png",
    "https://viafoura.com/wp-content/uploads/Dean-1.png",
    "https://viafoura.com/wp-content/uploads/Ken-1.png",
    "https://viafoura.com/wp-content/uploads/Eric-1.png",
    "https://viafoura.com/wp-content/uploads/Vlad-4.png",
    "https://viafoura.com/wp-content/uploads/Dan-1.png",
    "https://viafoura.com/wp-content/uploads/Mark-e1552417464120.png",
    "https://viafoura.com/wp-content/uploads/marco-3.png",
    "https://viafoura.com/wp-content/uploads/dougal.png",
    "https://viafoura.com/wp-content/uploads/Tim-e1552417361112.png",
    "https://viafoura.com/wp-content/uploads/William-e1552417333259.png",
    "https://viafoura.com/wp-content/uploads/Greg.png",
    "https://viafoura.com/wp-content/uploads/Leigh-e1552417485322.png",
    "https://viafoura.com/wp-content/uploads/Chris-e1552417673742.png",
    "https://viafoura.com/wp-content/uploads/Juli-e1552417552810.png",
    "https://viafoura.com/wp-content/uploads/Seto.png",
    "https://viafoura.com/wp-content/uploads/Jon-e1552417574830.png",
    "https://viafoura.com/wp-content/uploads/sam.png",
    "https://viafoura.com/wp-content/uploads/Hassan-e1552417607835.png",
    "https://viafoura.com/wp-content/uploads/Vincent.png",
    "https://viafoura.com/wp-content/uploads/KenVoort-e1552417525864.png",
    # "https://viafoura.com/wp-content/uploads/Josh-e1552417563756.png",
    "https://viafoura.com/wp-content/uploads/Mehrad-e1552417453247.png",
    # "https://viafoura.com/wp-content/uploads/Andres.png",
    "https://viafoura.com/wp-content/uploads/Aaron-e1552417713485.png",
    # "https://viafoura.com/wp-content/uploads/Connor-e1552417659986.png",
    # "https://viafoura.com/wp-content/uploads/Kristine-e1552417513413.png",
    "https://viafoura.com/wp-content/uploads/Shamil-e1552417724485.png",
    # "https://viafoura.com/wp-content/uploads/Kyle-e1552417501174.png",
    # "https://viafoura.com/wp-content/uploads/Alex-e1552411934273.png",
    # "https://viafoura.com/wp-content/uploads/Rakesh-e1552417439606.png",
    # "https://viafoura.com/wp-content/uploads/Jeremy.png",
    "https://viafoura.com/wp-content/uploads/Stefan-2.png",
    # "https://viafoura.com/wp-content/uploads/Sylvia-e1552417737741.png"
  ]

  def start_link(_ignore \\ nil) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  # Called by `live_render` in our template
  def render(assigns) do
  view_max = 300
  position_max = 800
  update_smoothing = 7
    ~L[
      <button phx-click="race-on">Race</button>
      <%= if @mode === :race do %>
        <button phx-click="race-start">Start</button>
      <% end %>
      <ol class="page-list">
      <%= for {page, count, title, url, img, rim, time, rank, roller_img} <- @time do %>
        <li
          class="page-item"
        >
          <h1><span><%= rank + 1 %></span>
              <%= if @mode !== :race do %>
              <div class="page-image-container">
                <img class="page-image" src="<%= img %>"/>
              </div>
              <% end %>
          </h1>
          <a href="<%= url %>">
            <%= title %>
          </a>
          <div class="page-content">
            <div class="page-meta">
              <p>
                <%= count %> views
              </p>
            </div>
             <%= if @mode === :race do %>
            <img
              class="rolling-image <%= if count > view_max do %>finisher<% end %>"
              src="<%= roller_img %>"
              style="transform: translateX(<%= min(Kernel.trunc(div(count, update_smoothing) * update_smoothing * (position_max /view_max)) , position_max) %>px) rotate(<%= Kernel.trunc(div(count, update_smoothing) * update_smoothing * 5) %>deg);"
            />
            <% end %>
          </div>
        </li>
      <% end %>
      </ol>
    ]
  end

  def handle_event("race-on", _, socket) do
    :timer.cancel(Process.get(:timer_ref))
    Logger.error("socket assigns")
    rt_list = real_time_list
    Process.put(:race_list, rt_list)
    Process.put(:avatar_list, Enum.shuffle(@roller_img_urls)|>Enum.take(Enum.count(rt_list)))
    {:noreply, assign(socket, mode: :race, time: zeros())} 
  end
  
  def handle_event("race-start", _, socket) do
    Logger.error(inspect(Supervisor.which_children(SturdyUmbrellaWeb.PageCache.Supervisor)))
    #send self(), :update_race
    Process.put(:race_list, reset_to_current())
    {ok, tref} = :timer.send_interval(@update_frequency, self(), :update_race)
    Process.put(:timer_ref, tref)
    GenServer.call(:Cache, :new_race)
    {:noreply, socket } 
  end

  def count_changed(thing) do
#     GenServer.call(SturdyUmbrellaWeb.ClockLive, :update)
#    send self(), :update
  end

  # Runs once, on page load
  def mount(_session, socket) do
    if connected?(socket) do
      {ok, tref} = :timer.send_interval(@update_frequency, self(), :update)
      Process.put(:timer_ref, tref)
    end

    {:ok, assign(socket, mode: :list, time: []) }
  end

  def handle_info(:update_race, socket) do
    {:noreply, update_race(socket)}
  end

  def handle_info(:update, socket) do
    {:noreply, update_time(socket)}
  end

  defp real_time_list() do
    Enum.sort(:ets.tab2list(:page_cache), fn (a, b) -> Kernel.elem(a, 1) > Kernel.elem(b, 1) end)
      |> Enum.take(10)
      |> Enum.with_index
      |> Enum.map(fn ({ values, i }) -> Tuple.append(values, i) end)
  end

  defp update_time(socket) do
  if socket.assigns[:mode] == :list do 
    assign(socket, time: real_time_list()|> Enum.map(fn (values) -> Tuple.append(values,"") end)) 
    else 
    socket
    end
  end

  defp get_uuid(thing) do
    Kernel.elem(thing, 0)
  end

  defp reset_to_current() do
    Process.get(:race_list)
    |> Enum.map(fn (thing) -> 
    from_table = get_from_table(get_uuid(thing))
    update_to_value(from_table, Kernel.elem(from_table, 1))
    end)
  end

  defp update_to_value(thing, v) do
          Tuple.delete_at(thing, 1)
          |>Tuple.insert_at(1, v)
  end

  defp get_from_table(uuid) do
          List.first(:ets.lookup(:page_cache, uuid))
  end

  defp zeros() do
    vals = Process.get(:race_list)
      |> Enum.map(fn (thing) ->
          update_to_value(thing, 0)
          end)
      |> Enum.zip(Process.get(:avatar_list))
      |> Enum.map(fn ({ values, i }) -> Tuple.append(values, i) end)
      Logger.error(inspect(vals))
      vals
  end

  defp update_race(socket) do
    vals = Process.get(:race_list)
      |> Enum.map(fn (thing) ->
          from_table = get_from_table(get_uuid(thing))
          update_value = Kernel.elem(from_table, 1) - Kernel.elem(thing, 1)
          update_to_value(from_table, update_value)
          end)
    
    counts = vals
    |> Enum.map(fn (thing) -> Kernel.elem(thing, 1) end)
    |> Enum.sort
    |> Enum.reverse
    
    ranked_vals = vals
    |> Enum.map(fn (val) -> Tuple.append(val, Enum.find_index(counts, fn x -> Kernel.elem(val,1) === x end)) end)
    |> Enum.zip(Process.get(:avatar_list))
    |> Enum.map(fn ({ values, i }) -> Tuple.append(values, i) end)

    assign(socket, time: ranked_vals)
  end
end
