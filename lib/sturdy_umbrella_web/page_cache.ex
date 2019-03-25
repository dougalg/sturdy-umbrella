defmodule SturdyUmbrellaWeb.PageCache do
  use GenServer
  require Logger

  def start_link(name \\ nil) do
  Logger.error("starting with name ", name)
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, [name: :Cache])
    :ets.new(:page_cache, [:set, :public, :named_table])
    GenServer.call(:Cache, :new_race)
    {:ok, pid}
  end

  def handle_call(:new_race, _from, state) do
    {ok, tref} = :timer.send_interval(30000, self(), :zombie) 
    Logger.error("new race started from")
    Logger.error(inspect(_from))
    {:reply, :poo, state}
  end

  def handle_info(:zombie, socket) do
    {ok, dt} = DateTime.now("Etc/UTC")
    :ets.tab2list(:page_cache)
    |> Enum.filter(fn record -> Kernel.elem(record, 6) <  (DateTime.to_unix(dt) - 300) * 1000 end)
    |> Enum.each(fn record -> Logger.error("removing thing")
    :ets.delete(:page_cache, Kernel.elem(record, 0)) end)
    {:noreply, socket}
  end

  # def increment_page_count(page_uuid) do
  #   :ets.update_counter(:page_cache, pageUuid, {2, 1}, {pageUuid, 0})
  # end
end
