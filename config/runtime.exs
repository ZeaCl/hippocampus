import Config

config :hippocampus, Hippocampus.Repo,
  url: System.get_env("DATABASE_URL", "postgresql://postgres:postgres_secure_password@postgres:5432/hippocampus_prod"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

config :hippocampus, HippocampusWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST", "hippocampus.zea.localhost"), port: 80],
  http: [port: String.to_integer(System.get_env("PORT", "4083"))],
  secret_key_base: System.get_env("SECRET_KEY_BASE", "dev-secret-CHANGE-ME-in-production-64bytes-minimum")

config :hippocampus, :thalamus,
  url: System.get_env("THALAMUS_URL", "http://thalamus:4000"),
  jwks_url: System.get_env("THALAMUS_URL", "http://thalamus:4000") <> "/.well-known/jwks.json"

config :hippocampus, :docker,
  socket: System.get_env("DOCKER_SOCKET", "/var/run/docker.sock"),
  compose_file: System.get_env("COMPOSE_FILE", "/workspace/platform/docker-compose.local.yml"),
  network: System.get_env("DOCKER_NETWORK", "zea_network_local")
