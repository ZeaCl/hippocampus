defmodule HippocampusWeb.Plugs.Guard do
  @moduledoc "Rejects unauthenticated requests."
  use Plug.Router

  plug :match
  plug :dispatch

  # If not authenticated by JWT or API Key, halt
  forward "/", to: HippocampusWeb.PreviewController,
    init_opts: &(%{authenticated: &1.assigns[:authenticated]})

  match _ do
    if not Map.get(conn.assigns, :authenticated, false) do
      conn |> send_resp(401, Jason.encode!(%{error: "unauthorized"})) |> halt()
    else
      conn
    end
  end
end
