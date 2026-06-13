defmodule Hippocampus.Preview do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "previews" do
    field :slug, :string
    field :branch, :string
    field :repo, :string
    field :status, :string, default: "creating"  # creating, running, stopped, failed, destroyed
    field :container_name, :string
    field :port, :integer
    field :url, :string
    field :metadata, :map, default: %{}
    field :created_by, :string
    field :organization_id, Ecto.UUID

    timestamps()
  end

  def changeset(preview, attrs) do
    preview
    |> cast(attrs, [:slug, :branch, :repo, :status, :container_name, :port, :url, :metadata, :created_by, :organization_id])
    |> validate_required([:slug, :branch, :repo, :organization_id])
    |> unique_constraint(:slug)
  end
end
