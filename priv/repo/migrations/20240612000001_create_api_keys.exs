defmodule Hippocampus.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :key_hash, :string, null: false
      add :key_prefix, :string, null: false
      add :scopes, {:array, :string}, default: []
      add :is_active, :boolean, default: true
      add :last_used_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :revoked_at, :utc_datetime
      add :organization_id, :uuid, null: false

      timestamps()
    end

    create unique_index(:api_keys, [:key_hash])
    create index(:api_keys, [:organization_id])
  end
end
