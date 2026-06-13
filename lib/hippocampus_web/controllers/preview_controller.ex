defmodule HippocampusWeb.PreviewController do
  use Plug.Router

  alias Hippocampus.Previews

  plug :match
  plug :dispatch

  # GET /api/v1/previews
  get "/previews" do
    org_id = conn.assigns[:org_id]
    previews = Previews.list(org_id)
    send_resp(conn, 200, Jason.encode!(%{data: previews, total: length(previews)}))
  end

  # GET /api/v1/previews/:slug
  get "/previews/:slug" do
    org_id = conn.assigns[:org_id]
    case Previews.get(org_id, slug) do
      nil -> send_resp(conn, 404, Jason.encode!(%{error: "not_found"}))
      p -> send_resp(conn, 200, Jason.encode!(%{data: p}))
    end
  end

  # POST /api/v1/previews
  post "/previews" do
    org_id = conn.assigns[:org_id]
    {:ok, body, conn} = read_body(conn)
    attrs = Jason.decode!(body)
    attrs = Map.put(attrs, "created_by", conn.assigns[:user_id])

    case Previews.create(org_id, attrs) do
      {:ok, preview} ->
        send_resp(conn, 201, Jason.encode!(%{data: preview}))
      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
        send_resp(conn, 422, Jason.encode!(%{error: "validation_failed", details: errors}))
      {:error, reason} ->
        send_resp(conn, 500, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  # DELETE /api/v1/previews/:slug
  delete "/previews/:slug" do
    org_id = conn.assigns[:org_id]
    case Previews.destroy(org_id, slug) do
      {:ok, _} -> send_resp(conn, 200, Jason.encode!(%{ok: true}))
      {:error, :not_found} -> send_resp(conn, 404, Jason.encode!(%{error: "not_found"}))
      {:error, reason} -> send_resp(conn, 500, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  # POST /api/v1/previews/:slug/restart
  post "/previews/:slug/restart" do
    org_id = conn.assigns[:org_id]
    case Previews.restart(org_id, slug) do
      {:ok, _} -> send_resp(conn, 200, Jason.encode!(%{ok: true}))
      {:error, :not_found} -> send_resp(conn, 404, Jason.encode!(%{error: "not_found"}))
    end
  end

  # GET /api/v1/previews/:slug/logs
  get "/previews/:slug/logs" do
    org_id = conn.assigns[:org_id]
    case Previews.logs(org_id, slug) do
      {:ok, logs} -> send_resp(conn, 200, Jason.encode!(%{logs: logs}))
      {:error, :not_found} -> send_resp(conn, 404, Jason.encode!(%{error: "not_found"}))
      {:error, reason} -> send_resp(conn, 500, Jason.encode!(%{error: inspect(reason)}))
    end
  end

  # POST /api/v1/api-keys
  post "/api-keys" do
    org_id = conn.assigns[:org_id]
    {:ok, body, conn} = read_body(conn)
    attrs = Jason.decode!(body)

    prefix = "zs_live_"
    raw_key = prefix <> (:crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false))
    key_hash = :crypto.hash(:sha256, raw_key) |> Base.encode64()

    key_attrs = %{
      name: attrs["name"] || "default",
      key_hash: key_hash,
      key_prefix: prefix,
      scopes: attrs["scopes"] || ["previews:read", "previews:write"],
      organization_id: org_id
    }

    case %Hippocampus.ApiKey{} |> Hippocampus.ApiKey.changeset(key_attrs) |> Hippocampus.Repo.insert() do
      {:ok, _} ->
        send_resp(conn, 201, Jason.encode!(%{api_key: raw_key, prefix: prefix, scopes: key_attrs.scopes}))
      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
        send_resp(conn, 422, Jason.encode!(%{error: "validation_failed", details: errors}))
    end
  end

  # Fallback
  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "not_found"}))
  end
end
