defmodule SturdyUmbrellaWeb.PageCache do
  use GenServer

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    # GenServer.call(pid, :page_cache)
    {:ok, pid}
  end

  def handle_call(:asd, _from, _) do
    :ets.new(:page_cache, [:set, :public, :named_table])
  end
end
