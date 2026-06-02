# Fabriq Geoscience Landing Page

Lead-generation landing page for Fabriq expert AI agents in geoscience. Static Astro site + Dockerized Hono API + Supabase + Resend.

## Stack

- **Web:** Astro (`apps/web`)
- **API:** Hono on Node 20 (`services/api`)
- **DB:** Supabase Postgres (`supabase/migrations/001_leads.sql`)
- **Deploy:** Caddy (Let's Encrypt) + API on one VM (`scripts/deploy.sh`)

## Quick start (local)

```bash
pnpm install

# 1. Copy env and fill Supabase + optional Resend
cp .env.example .env

# 2. Run migration in Supabase SQL Editor (see supabase/migrations/001_leads.sql)

# 3. API
pnpm dev:api
# or: docker compose -f docker/docker-compose.dev.yml up --build

# 4. Web
PUBLIC_API_URL=http://localhost:3000 pnpm dev:web
```

Open http://localhost:4321

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
