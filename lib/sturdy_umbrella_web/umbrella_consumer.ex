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
    if body["event_type"] === "analytics.view"
    do
      body
      |>get_in(["view"])
      |>get_in(["pageUuid"])
      |>store_uuid
      |>SturdyUmbrellaWeb.ClockLive.count_changed
    end

    :ok
  end

  def get_body(map) do
    {:ok, body} = map
    body
  end

  def store_uuid(pageUuid) do
    :ets.update_counter(@name, pageUuid, {2, 1}, {pageUuid, 0})
  end

end
