defmodule HippocampusWeb.Plugs.AuthRouter do
  use Plug.Router

  plug HippocampusWeb.Plugs.JWTAuth
  plug HippocampusWeb.Plugs.ApiKeyAuth
  plug :match
  plug :dispatch

  # Guard: require authentication for all API routes
  forward "/v1", to: HippocampusWeb.Plugs.Guard
end
