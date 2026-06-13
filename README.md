# 🧠 Hippocampus — Preview & Environment Manager

**Spin up isolated preview environments for every branch.**

[![Elixir](https://img.shields.io/badge/elixir-1.18-purple)](https://elixir-lang.org)
[![Phoenix](https://img.shields.io/badge/phoenix-1.7-orange)](https://phoenixframework.org)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)

---

## 🎯 What is Hippocampus?

Just like the brain's hippocampus stores and retrieves memories of context,
**ZEA Hippocampus** creates, tracks, and tears down isolated preview environments
for your development branches.

Each branch gets its own full-stack deployment — database, backend, frontend —
accessible at a unique URL. No more "it works on my machine."

### Features

- ✅ **Branch Previews** — One command to deploy any branch
- ✅ **Isolated Environments** — Each preview has its own containers
- ✅ **Automatic Cleanup** — Destroy previews when branches are merged
- ✅ **API First** — REST API with API Key auth for CI/CD
- ✅ **Thalamus Integration** — JWT auth for human users
- ✅ **CLI** — `zea-hippocampus` for terminal workflows
- ✅ **AI Agent Skill** — AI agents can create previews from chat

---

## 🚀 Quickstart

```bash
# 1. Get an API key
curl -X POST http://hippocampus.zea.localhost/api/v1/api-keys \
  -H "Authorization: Bearer $ZEA_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"my-key","scopes":["previews:read","previews:write"]}'

# 2. Install CLI
npm install -g zea-hippocampus
export HIPPOCAMPUS_KEY=zs_live_...

# 3. Create a preview
zea-hippocampus create --branch feature/my-feature
# ✅ Preview created: feature-my-feature-427
#    URL: http://preview-feature-my-feature-427.zea.localhost

# 4. Check it
zea-hippocampus list
# 🟢 feature-my-feature-427    feature/my-feature    http://preview-...
```

---

## 📡 API Reference

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/previews` | List all previews |
| `POST` | `/api/v1/previews` | Create a new preview |
| `GET` | `/api/v1/previews/:slug` | Get preview details |
| `DELETE` | `/api/v1/previews/:slug` | Destroy a preview |
| `POST` | `/api/v1/previews/:slug/restart` | Restart a preview |
| `GET` | `/api/v1/previews/:slug/logs` | Get container logs |
| `POST` | `/api/v1/api-keys` | Create an API key |

### Auth

Send either a **JWT Bearer token** (from Thalamus) or an **API Key** header:

```bash
# Human users (JWT)
curl -H "Authorization: Bearer eyJ..." http://hippocampus.zea.localhost/api/v1/previews

# CI/CD pipelines (API Key)
curl -H "x-api-key: zs_live_..." http://hippocampus.zea.localhost/api/v1/previews
```

---

## 🏗️ Architecture

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│  Developer   │────▶│ Hippocampus  │────▶│ Docker Compose   │
│  (CLI/Chat)  │     │  (REST API)  │     │  (preview_xxx)   │
└──────────────┘     └──────┬───────┘     └──────────────────┘
                            │
                     ┌──────▼───────┐
                     │   Thalamus   │
                     │   (Auth)     │
                     └──────────────┘
```

---

## 🔧 Self-hosting

```bash
# Clone
git clone https://github.com/zeacl/hippocampus
cd hippocampus

# Add to your ZEA Platform
# In docker-compose.yml:
hippocampus:
  build: ../hippocampus
  ports: ["4083:4083"]
  volumes: ["/var/run/docker.sock:/var/run/docker.sock"]
  environment:
    DATABASE_URL: "postgresql://..."
    THALAMUS_URL: "http://thalamus:4000"

# In Caddyfile:
http://hippocampus.zea.localhost {
    reverse_proxy hippocampus:4083
}
```

---

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE)
