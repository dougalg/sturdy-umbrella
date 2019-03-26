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
    {ok, tref} = :timer.send_interval(3000, self(), :zombie) 
    Logger.error("new race started from")
    Logger.error(inspect(_from))
    {:reply, :poo, state}
  end

  def handle_info(:zombie, socket) do
    {ok, dt} = DateTime.now("Etc/UTC")
    :ets.tab2list(:page_cache)
    |> Enum.filter(fn (record) -> 
        diff = DateTime.to_unix(dt) * 1000 - Kernel.elem(record, 6) 
          if(diff > 300000) do
          Logger.error("Diff was #{diff}, #{Kernel.elem(record, 2)}")
          true
          else
            false
          end
          end)
    |> Enum.each(fn record ->
    :ets.delete(:page_cache, Kernel.elem(record, 0)) end)
    {:noreply, socket}
  end

  # def increment_page_count(page_uuid) do
  #   :ets.update_counter(:page_cache, pageUuid, {2, 1}, {pageUuid, 0})
  # end
end
