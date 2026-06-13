defmodule Hippocampus.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Hippocampus.Repo,
      {Phoenix.PubSub, name: Hippocampus.PubSub},
      HippocampusWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Hippocampus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
