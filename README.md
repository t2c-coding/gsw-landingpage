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
- API: http://localhost:3022 (`/health`, `/v1/leads`) — published for host Astro dev only

### Option B — Full stack in Docker (no host `npm` required)

From the repo root:

```bash
./scripts/ensure-env.sh
docker compose -f docker/docker-compose.local.yml up --build
```

Docker builds the Astro site (`npm ci` + `npm run build` inside the `web` image) and starts API + Caddy.

- Site: http://localhost:8080 (Caddy — only public port)
- API: internal only (`http://api:3022` from Caddy); health at http://localhost:8080/api/health

Rebuild after code changes: `docker compose -f docker/docker-compose.local.yml up --build`

Stop: `docker compose -f docker/docker-compose.local.yml down`

### Production-like stack (VM — needs real DNS + Let's Encrypt)

```bash
./scripts/deploy.sh
```

Uses `docker/docker-compose.yml` (Caddy TLS on 80/443 + `DOMAIN` in `.env`; API not exposed on the host). Not for everyday local dev.

## Production deploy

1. Provision Ubuntu VM (1 vCPU, 1GB RAM min), install **Docker** (Node/npm on the host are not required).
2. Point DNS `DOMAIN` → VM; open ports 80, 443.
3. Create Supabase project; run `001_leads.sql`.
4. Copy `.env` on VM from `.env.example` (all keys filled).
5. Run:

```bash
chmod +x scripts/deploy.sh scripts/export-leads.sh
./scripts/deploy.sh
```

Exit code **0** = delivery verified (HTTPS, health, test lead, page markers).

Flags: `--verify-only`, `--skip-build`, `--skip-lead-test`, `--skip-dns-check`

### Updating a running production stack

When new code is merged, update the VM from the **repo root** (same directory as `.env`). You only need **Docker** and **git** on the host — not Node/npm.

**1. Pull the latest code**

```bash
cd /path/to/fabriq-landing-page   # your clone on the VM
git pull
```

**2. Redeploy (recommended)**

This rebuilds the Astro site into `apps/web/dist`, rebuilds the API and Caddy images if needed, recreates containers, and runs HTTPS/health/lead checks:

```bash
./scripts/deploy.sh
```

What `deploy.sh` does on each run:

| Step | Effect |
|------|--------|
| Web build | Docker `node:20-alpine` runs `npm ci && npm run build` → `apps/web/dist` (uses `PUBLIC_API_URL=https://${DOMAIN}/api`) |
| `docker compose build` | Rebuilds `api` and `caddy` images when Dockerfiles or dependencies changed |
| `docker compose up -d` | Restarts stack; Caddy serves new static files from the mounted `dist` volume |
| Verification | `curl` health, homepage, optional test lead POST, page markers |

Expect a few seconds of downtime while containers restart. TLS certificates in the `caddy_data` volume are kept across deploys.

**3. Faster options (when appropriate)**

| Change type | Command |
|-------------|---------|
| Copy / content / Astro only | `./scripts/deploy.sh` (web rebuild is quick; API image may cache) |
| `.env` only (no code) | `docker compose -f docker/docker-compose.yml --env-file .env up -d` |
| Smoke test after manual steps | `./scripts/deploy.sh --skip-build` |
| Skip test lead POST | `./scripts/deploy.sh --skip-lead-test` |

**4. Manual update (equivalent to deploy without verification)**

```bash
set -a && source .env && set +a
export PUBLIC_API_URL="https://${DOMAIN}/api"
export CADDYFILE="${PWD}/docker/Caddyfile"   # or Caddyfile.cloudflare if using CLOUDFLARE_API_TOKEN

# Build static site (no host npm)
docker run --rm -v "$(pwd)/apps/web:/app" -w /app \
  -e "PUBLIC_API_URL=${PUBLIC_API_URL}" node:20-alpine \
  sh -c "npm ci && npm run build"

docker compose -f docker/docker-compose.yml --env-file .env build
docker compose -f docker/docker-compose.yml --env-file .env up -d
```

**5. Check logs if something fails**

```bash
docker compose -f docker/docker-compose.yml logs -f caddy
docker compose -f docker/docker-compose.yml logs -f api
```

**6. Roll back**

Check out the previous git revision on the VM, then run `./scripts/deploy.sh` again. Old images may remain cached; `docker compose build` picks up the checked-out code.

Do not commit `.env` to git; keep production secrets only on the VM.

### TLS / Cloudflare troubleshooting

If Caddy logs show ACME **404** on `/.well-known/acme-challenge/` and an IP like `2606:4700:…`, **Let's Encrypt is hitting Cloudflare**, not your VM. Caddy on the server never receives the challenge.

**Fix A — DNS only (simplest):** In Cloudflare, set the `DOMAIN` record to **DNS only** (grey cloud). Point A/AAAA to your VM. Wait a few minutes, then:

```bash
docker compose -f docker/docker-compose.yml restart caddy
# or full redeploy
./scripts/deploy.sh
```

**Fix B — Keep Cloudflare proxy:** Create an API token with **Zone → DNS → Edit** for the zone, add to `.env`:

```bash
CLOUDFLARE_API_TOKEN=your_token
```

Redeploy; `deploy.sh` switches to **DNS-01** ACME via `docker/Caddyfile.cloudflare`.

**Cloudflare SSL mode** (when using proxy): set SSL/TLS to **Full (strict)** once the origin has a valid cert.

## Env vars

See [.env.example](.env.example).

## Docs

- [plan.md](plan.md) — full spec
- [BRAND.md](BRAND.md) — colors and assets
