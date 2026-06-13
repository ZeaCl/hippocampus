defmodule HippocampusWeb.Plugs.ApiKeyAuth do
  @moduledoc "Validates API Key (zs_live_...) for programmatic access."

  import Plug.Conn
  alias Hippocampus.{Repo, ApiKey}

  def init(opts), do: opts

  def call(%{assigns: %{authenticated: true}} = conn, _opts), do: conn  # already authed via JWT

  def call(conn, _opts) do
    case get_req_header(conn, "x-api-key") do
      [raw_key | _] when byte_size(raw_key) > 20 ->
        key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

        case Repo.get_by(ApiKey, key_hash: key_hash, is_active: true) do
          %ApiKey{organization_id: org_id, scopes: scopes} = key ->
            Hippocampus.ApiKey.touch_last_used(key)
            conn
            |> assign(:org_id, org_id)
            |> assign(:api_key_scopes, scopes)
            |> assign(:authenticated, true)

          nil ->
            conn |> json_error(401, "invalid_api_key") |> halt()
        end

      _ ->
        conn |> json_error(401, "missing_authentication") |> halt()
    end
  end

  defp json_error(conn, status, detail) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(%{error: "unauthorized", detail: detail}))
  end
end
