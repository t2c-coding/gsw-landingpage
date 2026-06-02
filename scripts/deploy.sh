#!/usr/bin/env bash
# Fabriq landing — build, deploy (api + caddy), verify delivery.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

source "$ROOT/scripts/lib/deploy-common.sh"

VERIFY_ONLY=false
SKIP_BUILD=false
SKIP_LEAD_TEST=false
SKIP_DNS_CHECK=false

for arg in "$@"; do
  case "$arg" in
    --verify-only) VERIFY_ONLY=true ;;
    --skip-build) SKIP_BUILD=true ;;
    --skip-lead-test) SKIP_LEAD_TEST=true ;;
    --skip-dns-check) SKIP_DNS_CHECK=true ;;
  esac
done

"$ROOT/scripts/ensure-env.sh"
set -a
# shellcheck disable=SC1091
source "$ROOT/.env"
set +a

: "${DOMAIN:?Set DOMAIN in .env}"
: "${ACME_EMAIL:?Set ACME_EMAIL in .env}"

BASE_URL="https://${DOMAIN}"
API_URL="${BASE_URL}/api"
export PUBLIC_API_URL="${API_URL}"

if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
  export CADDYFILE="${ROOT}/docker/Caddyfile.cloudflare"
  log "ACME: Cloudflare DNS-01 (orange-cloud proxy OK)"
elif [ "$SKIP_DNS_CHECK" = false ]; then
  export CADDYFILE="${ROOT}/docker/Caddyfile"
  check_acme_dns "$DOMAIN"
else
  export CADDYFILE="${ROOT}/docker/Caddyfile"
fi

if [ "$VERIFY_ONLY" = false ]; then
  if [ "$SKIP_BUILD" = false ]; then
    if ! command -v docker >/dev/null 2>&1; then
      log "docker is required on the host (npm is not)"
      exit 1
    fi

    log "Building web (PUBLIC_API_URL=$PUBLIC_API_URL)…"
    build_web_dist "$ROOT" "$PUBLIC_API_URL"

    log "Building API + Caddy images…"
    docker compose -f docker/docker-compose.yml build
  fi

  log "Starting stack (api + caddy)…"
  export DOMAIN ACME_EMAIL CADDYFILE
  docker compose -f docker/docker-compose.yml --env-file .env up -d
fi

log "Waiting for TLS + health (up to ~120s)…"
retry_curl "${API_URL}/health" 30 4 || {
  log "Health check failed at ${API_URL}/health"
  exit 1
}

log "Verify: HTTPS homepage"
curl -fsS "${BASE_URL}/" -o /dev/null

log "Verify: TLS for ${DOMAIN}"
echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null \
  | openssl x509 -noout -subject 2>/dev/null | grep -q "${DOMAIN}" || {
  log "Warning: could not confirm cert subject contains DOMAIN"
}

log "Verify: API health JSON"
HEALTH=$(curl -fsS "${API_URL}/health")
echo "$HEALTH" | grep -q '"ok":true' || {
  log "Health response not ok: $HEALTH"
  exit 1
}

if [ "$SKIP_LEAD_TEST" = false ]; then
  TEST_EMAIL="${DEPLOY_TEST_EMAIL:-deploy-verify@example.com}"
  log "Verify: POST test lead"
  RESP=$(curl -fsS -X POST "${API_URL}/v1/leads" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${TEST_EMAIL}\",\"name\":\"Deploy Verify\",\"company\":\"Fabriq CI\",\"website\":\"\",\"campaign\":\"geoscience\"}")
  echo "$RESP" | grep -q 'leadId' || {
    log "Lead POST response missing leadId: $RESP"
    exit 1
  }

  if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
    LEAD_ID=$(echo "$RESP" | sed -n 's/.*"leadId":"\([^"]*\)".*/\1/p')
    if [ -n "$LEAD_ID" ] && [ "$LEAD_ID" != "ignored" ]; then
      log "Verify: Supabase row ${LEAD_ID}"
      curl -fsS "${SUPABASE_URL}/rest/v1/leads?id=eq.${LEAD_ID}&select=id" \
        -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
        | grep -q "$LEAD_ID" || {
        log "Lead not found in Supabase"
        exit 1
      }
    fi
  fi
fi

log "Verify: geoscience page markers"
HTML=$(curl -fsS "${BASE_URL}/")
echo "$HTML" | grep -q 'data-campaign="geoscience"' || exit 1
echo "$HTML" | grep -q 'Schweinsteiger' || exit 1

log "Delivery OK — ${BASE_URL}"
exit 0
