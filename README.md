# Fabriq Geoscience Landing Page

Lead-generation landing page for Fabriq expert AI agents in geoscience. Static Astro site + Dockerized Hono API + Supabase.

## Stack

- **Web:** Astro (`apps/web`)
- **API:** Hono on Node 20 (`services/api`)
- **DB:** Supabase Postgres (`supabase/migrations/001_leads.sql`)
- **Deploy:** Caddy (Let's Encrypt) + API on one VM (`scripts/deploy.sh`)

## Quick start (local)

```bash
pnpm install

# 1. Copy env and fill Supabase credentials
cp .env.example .env

# 2. Run migration in Supabase SQL Editor (see supabase/migrations/001_leads.sql)

# 3. API (from repo root .env)
cd services/api && npm install && npm run dev

# 4. Web (PUBLIC_API_URL in apps/web/.env → http://localhost:3022)
cd apps/web && npm run dev
```

Open http://localhost:4321

## Docker (local)

```bash
./scripts/ensure-env.sh   # creates .env from .env.example if missing; checks Supabase keys
```

### Option A — API only (Astro dev server for the site)

```bash
docker compose -f docker/docker-compose.local-dev.yml up --build
```

In another terminal:

```bash
cd apps/web && npm run dev
```

- Site: http://localhost:4321 (hot reload)
- API: http://localhost:3022 (`/health`, `/v1/leads`)

### Option B — Full stack in Docker (no host `npm` required)

From the repo root:

```bash
./scripts/ensure-env.sh
docker compose -f docker/docker-compose.local.yml up --build
```

Docker builds the Astro site (`npm ci` + `npm run build` inside the `web` image) and starts API + Caddy.

- Site: http://localhost:8080
- Health: http://localhost:8080/api/health

Rebuild after code changes: `docker compose -f docker/docker-compose.local.yml up --build`

Stop: `docker compose -f docker/docker-compose.local.yml down`

### Production-like stack (VM — needs real DNS + Let's Encrypt)

```bash
./scripts/deploy.sh
```

Uses `docker/docker-compose.yml` (Caddy TLS + `DOMAIN` in `.env`). Not for everyday local dev.

## Production deploy

1. Provision Ubuntu VM (1 vCPU, 1GB RAM min), install Docker.
2. Point DNS `DOMAIN` → VM; open ports 80, 443.
3. Create Supabase project; run `001_leads.sql`.
4. Copy `.env` on VM from `.env.example` (all keys filled).
5. Run:

```bash
chmod +x scripts/deploy.sh scripts/export-leads.sh
./scripts/deploy.sh
```

Exit code **0** = delivery verified (HTTPS, health, test lead, page markers).

Flags: `--verify-only`, `--skip-build`, `--skip-lead-test`

## Env vars

See [.env.example](.env.example).

## Docs

- [plan.md](plan.md) — full spec
- [BRAND.md](BRAND.md) — colors and assets
