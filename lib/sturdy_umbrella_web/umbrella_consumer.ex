defmodule SturdyUmbrellaWeb.KafkaConsumer do

  @name :page_cache
  @roller_default_img "https://viafoura.com/wp-content/uploads/NoPicture-1.png"
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
    "https://viafoura.com/wp-content/uploads/NoPicture-1.png", # Bira
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
    "https://viafoura.com/wp-content/uploads/NoPicture-1.png",  # Mick
    # "https://viafoura.com/wp-content/uploads/Sylvia-e1552417737741.png"
  ]
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

  def get_roller_img() do
    idx = Enum.random(0..length(@roller_img_urls) - 1)
    res = List.pop_at(@roller_img_urls, idx, @roller_default_img)
    # @roller_img_urls = elem(res, 1)
    elem(res, 0)
  end

  def store_uuid(body) do
    page_uuid = get_page_uuid(body)
    title = get_title(body)
    url = get_url(body)
    img = get_img(body)
    time = get_time(body)
    roller_img = get_roller_img()
    :ets.update_counter(@name, page_uuid, {2, 1}, {page_uuid, 0, title, url, img, roller_img, time })
  end

end
