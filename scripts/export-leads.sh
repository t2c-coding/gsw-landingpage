#!/usr/bin/env bash
# Export leads CSV from Supabase REST API.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
[ -f "$ROOT/.env" ] && source "$ROOT/.env"

: "${SUPABASE_URL:?}"
: "${SUPABASE_SERVICE_ROLE_KEY:?}"

curl -fsS "${SUPABASE_URL}/rest/v1/leads?select=*&order=created_at.desc" \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Accept: text/csv" \
  -H "Content-Profile: public"
