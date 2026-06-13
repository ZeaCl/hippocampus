defmodule Hippocampus.DockerManager do
  @moduledoc "Manages Docker containers for preview environments via docker-compose."

  alias Hippocampus.Preview

  @doc "Creates a preview container for a branch."
  def create_preview(%Preview{} = preview) do
    container_name = "sudlich_preview_#{preview.slug}"
    compose_file = Application.get_env(:hippocampus, :docker)[:compose_file]
    network = Application.get_env(:hippocampus, :docker)[:network]

    # Build and run using docker compose
    cmd = ~s(docker compose -f #{compose_file} -p preview_#{preview.slug} up -d --build sudlich-app)

    case System.cmd("sh", ["-c", cmd], stderr_to_stdout: true, timeout: 120_000) do
      {output, 0} ->
        # Add Caddy route for the preview
        caddy_cmd = ~s(docker exec zea_caddy_local sh -c 'echo "http://preview-#{preview.slug}.zea.localhost { reverse_proxy #{container_name}:3000 }" > /etc/caddy/sites/preview-#{preview.slug}.conf && caddy reload --config /etc/caddy/Caddyfile')
        System.cmd("sh", ["-c", caddy_cmd], timeout: 10_000)
        {:ok, container_name}

      {output, code} ->
        {:error, "Docker compose failed (exit #{code}): #{String.slice(output, 0, 500)}"}
    end
  end

  @doc "Destroy a preview container."
  def destroy_preview(%Preview{} = preview) do
    compose_file = Application.get_env(:hippocampus, :docker)[:compose_file]

    # Stop and remove containers
    cmd = ~s(docker compose -f #{compose_file} -p preview_#{preview.slug} down -v --remove-orphans 2>&1)
    System.cmd("sh", ["-c", cmd], timeout: 30_000)

    # Remove Caddy route
    caddy_cmd = ~s(docker exec zea_caddy_local sh -c 'rm -f /etc/caddy/sites/preview-#{preview.slug}.conf && caddy reload --config /etc/caddy/Caddyfile' 2>&1)
    System.cmd("sh", ["-c", caddy_cmd], timeout: 10_000)

    # Clean networks
    _ = System.cmd("sh", ["-c", "docker network prune -f 2>&1"], timeout: 10_000)

    {:ok, :destroyed}
  end

  @doc "Restart a preview container."
  def restart_preview(%Preview{} = preview) do
    cmd = ~s(docker restart #{preview.container_name || "sudlich_preview_#{preview.slug}"} 2>&1)
    System.cmd("sh", ["-c", cmd], timeout: 30_000)
  end

  @doc "Get logs from a preview container."
  def logs(%Preview{} = preview, tail \\ 100) do
    container = preview.container_name || "sudlich_preview_#{preview.slug}"
    cmd = ~s(docker logs --tail #{tail} #{container} 2>&1)

    case System.cmd("sh", ["-c", cmd], timeout: 10_000) do
      {logs, 0} -> {:ok, logs}
      {error, _} -> {:error, error}
    end
  end
end
