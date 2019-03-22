defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :sturdy_umbrella

  socket "/live", Phoenix.LiveView.Socket
end
