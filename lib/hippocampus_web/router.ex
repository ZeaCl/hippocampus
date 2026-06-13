defmodule HippocampusWeb.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  # Public endpoints
  get "/health" do
    send_resp(conn, 200, Jason.encode!(%{status: "ok", service: "hippocampus"}))
  end

  # Auth pipeline (JWT or API Key)
  forward "/api", to: HippocampusWeb.Plugs.AuthRouter
end
