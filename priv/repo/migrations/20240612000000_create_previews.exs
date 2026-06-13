defmodule Hippocampus.Repo.Migrations.CreatePreviews do
  use Ecto.Migration

  def change do
    create table(:previews, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :branch, :string, null: false
      add :repo, :string, null: false
      add :status, :string, null: false, default: "creating"
      add :container_name, :string
      add :port, :integer
      add :url, :string
      add :metadata, :map, default: %{}
      add :created_by, :string
      add :organization_id, :uuid, null: false

      timestamps()
    end

    create unique_index(:previews, [:slug])
    create index(:previews, [:organization_id])
    create index(:previews, [:status])
  end
end
