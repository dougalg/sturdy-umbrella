defmodule SturdyUmbrellaWeb.KafkaConsumer do

  @name :page_cache
  require Logger

  # function to accept Kafka messaged MUST be named "handle_message"
  # MUST accept arguments structured as shown here
  # MUST return :ok
  # Can do anything else within the function with the incoming message
  def handle_message(%{key: key, value: value} = message) do
    body = Jason.decode(value)
      |>get_body
    #Logger.debug(inspect(body))
    if body["event_type"] === "analytics.view" && get_in(body, ["meta", "page_type"]) === "article"
    do
      body
      |>store_uuid
      |>SturdyUmbrellaWeb.ClockLive.count_changed
    end

    :ok
  end

  def get_body(map) do
    {:ok, body} = map
    body
  end

  def get_page_uuid(body) do
    body
    |>get_in(["view", "pageUuid"])
  end

  def get_title(body) do
    body
    |>get_in(["meta"])
    |>get_in(["title"])
  end

  def get_url(body) do
    body
    |>get_in(["meta"])
    |>get_in(["url"])
  end

  def get_img(body) do
    body
    |>get_in(["meta"])
    |>get_in(["pageImage"])
  end

  def get_time(body) do
    body
    |>get_in(["time"])
  end

  def store_uuid(body) do
    {ok, dt} = DateTime.now("Etc/UTC")
    page_uuid = get_page_uuid(body)
    title = get_title(body)
    url = get_url(body)
    img = get_img(body)
    time = DateTime.to_unix(dt) * 1000
    :ets.update_counter(@name, page_uuid, {2, 1}, {page_uuid, 0, title, url, img, "", time })
    ok = :ets.update_element(@name, page_uuid, {7, time})
  end

end
