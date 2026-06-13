import Config

config :hippocampus, Hippocampus.Repo,
  url: System.get_env("DATABASE_URL", "postgresql://postgres:postgres_secure_password@localhost:5432/hippocampus_prod"),
  pool_size: 10

config :hippocampus, HippocampusWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [formats: [json: HippocampusWeb.ErrorJSON]],
  pubsub_server: Hippocampus.PubSub

config :hippocampus, :thalamus,
  url: System.get_env("THALAMUS_URL", "http://thalamus:4000"),
  jwks_url: "http://thalamus:4000/.well-known/jwks.json"

config :hippocampus, :docker,
  socket: System.get_env("DOCKER_SOCKET", "/var/run/docker.sock"),
  compose_file: System.get_env("COMPOSE_FILE", "/workspace/platform/docker-compose.local.yml"),
  network: System.get_env("DOCKER_NETWORK", "zea_network_local")

config :logger, level: :info
