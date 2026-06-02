#!/usr/bin/env bash
# Ensure repo-root .env exists before docker compose / deploy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
EXAMPLE="$ROOT/.env.example"

if [ ! -f "$ENV_FILE" ]; then
  if [ -f "$EXAMPLE" ]; then
    cp "$EXAMPLE" "$ENV_FILE"
    echo "[ensure-env] Created $ENV_FILE from .env.example"
    echo "[ensure-env] Edit it and set SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY, then re-run."
    exit 1
  else
    echo "[ensure-env] Missing $ENV_FILE and $EXAMPLE"
    exit 1
  fi
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

missing=0
for var in SUPABASE_URL SUPABASE_SERVICE_ROLE_KEY; do
  val="${!var:-}"
  if [ -z "$val" ] || [ "$val" = "https://xxxx.supabase.co" ]; then
    echo "[ensure-env] $var is not set in $ENV_FILE"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "[ensure-env] OK — $ENV_FILE"
exit 0
