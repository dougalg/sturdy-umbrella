defmodule SturdyUmbrellaWeb.PageCache do
  use GenServer

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    :ets.new(:page_cache, [:set, :public, :named_table])
    {:ok, pid}
  end

  def handle_call(:asd, _from, _) do
  end

  # def increment_page_count(page_uuid) do
  #   :ets.update_counter(:page_cache, pageUuid, {2, 1}, {pageUuid, 0})
  # end
end
