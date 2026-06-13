defmodule Hippocampus.Previews do
  @moduledoc "Preview environment lifecycle management."

  import Ecto.Query
  alias Hippocampus.{Repo, Preview}
  alias Hippocampus.DockerManager

  @doc "List previews for an organization."
  def list(org_id) do
    Repo.all(from p in Preview, where: p.organization_id == ^org_id, order_by: [desc: p.inserted_at])
  end

  @doc "Get a single preview by slug."
  def get(org_id, slug) do
    Repo.get_by(Preview, organization_id: org_id, slug: slug)
  end

  @doc "Create a new preview environment."
  def create(org_id, attrs) do
    slug = generate_slug(attrs["branch"])
    port = find_available_port()

    preview_attrs = %{
      slug: slug,
      branch: attrs["branch"],
      repo: attrs["repo"] || "sudlich-app",
      status: "creating",
      port: port,
      url: "http://preview-#{slug}.zea.localhost",
      created_by: attrs["created_by"],
      organization_id: org_id,
      metadata: attrs["metadata"] || %{}
    }

    with {:ok, preview} <- %Preview{} |> Preview.changeset(preview_attrs) |> Repo.insert(),
         {:ok, container} <- DockerManager.create_preview(preview) do
      preview
      |> Preview.changeset(%{status: "running", container_name: container})
      |> Repo.update()
    else
      {:error, %Ecto.Changeset{} = cs} ->
        {:error, cs}
      {:error, reason} ->
        # Mark as failed
        case Repo.get_by(Preview, slug: slug) do
          nil -> {:error, reason}
          p -> Repo.update(Preview.changeset(p, %{status: "failed"}))
        end
    end
  end

  @doc "Stop and remove a preview."
  def destroy(org_id, slug) do
    case Repo.get_by(Preview, organization_id: org_id, slug: slug) do
      nil -> {:error, :not_found}
      preview ->
        DockerManager.destroy_preview(preview)
        Repo.update(Preview.changeset(preview, %{status: "destroyed"}))
    end
  end

  @doc "Restart a preview container."
  def restart(org_id, slug) do
    case Repo.get_by(Preview, organization_id: org_id, slug: slug) do
      nil -> {:error, :not_found}
      preview ->
        DockerManager.restart_preview(preview)
        {:ok, preview}
    end
  end

  @doc "Get logs for a preview container."
  def logs(org_id, slug, tail \\ 100) do
    case Repo.get_by(Preview, organization_id: org_id, slug: slug) do
      nil -> {:error, :not_found}
      preview -> DockerManager.logs(preview, tail)
    end
  end

  # ── Private ──

  defp generate_slug(branch) do
    slug = branch
      |> String.replace(~r/[^a-zA-Z0-9_-]/, "-")
      |> String.replace(~r/-+/, "-")
      |> String.trim("-")
      |> String.downcase()
      |> String.slice(0, 40)

    slug <> "-#{:rand.uniform(999)}"
  end

  defp find_available_port do
    4100 + :rand.uniform(100)
  end
end
