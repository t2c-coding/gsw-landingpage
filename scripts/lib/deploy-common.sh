#!/usr/bin/env bash
set -euo pipefail

retry_curl() {
  local url="$1"
  local max="${2:-30}"
  local wait="${3:-4}"
  local i=0
  while [ "$i" -lt "$max" ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    i=$((i + 1))
    sleep "$wait"
  done
  return 1
}

log() {
  echo "[deploy] $*"
}

# Cloudflare proxy ranges (orange cloud) — LE http-01/tls-alpn never reach the VM.
is_cloudflare_proxy_ip() {
  local ip="$1"
  case "$ip" in
    104.*|172.6[4-9].*|172.7[0-1].*|2606:4700:*|2606:4701:*) return 0 ;;
  esac
  return 1
}

# Advisory only — do not block redeploys when Cloudflare proxy is intentional and TLS already works.
check_acme_dns() {
  local domain="$1"
  if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
    return 0
  fi

  if ! command -v dig >/dev/null 2>&1; then
    return 0
  fi

  local ip
  local proxied=false
  while read -r ip; do
    [ -z "$ip" ] && continue
    if is_cloudflare_proxy_ip "$ip"; then
      proxied=true
      log "Note: ${domain} resolves via Cloudflare proxy (${ip})"
    fi
  done < <(dig +short A "$domain" AAAA "$domain" 2>/dev/null)

  if [ "$proxied" = true ]; then
    log "Redeploy will continue. HTTP-01 ACME only fails if Caddy must issue a *new* cert and cannot reach your VM."
    log "If TLS breaks after a fresh install, use grey-cloud DNS or set CLOUDFLARE_API_TOKEN (see README)."
    if [ "${STRICT_ACME_DNS_CHECK:-}" = "1" ]; then
      log "STRICT_ACME_DNS_CHECK=1 — aborting (unset to allow deploy behind Cloudflare)."
      return 1
    fi
  fi

  return 0
}

# Build Astro static site without host Node/npm (dist → apps/web/dist).
build_web_dist() {
  local root="$1"
  local public_api_url="$2"
  docker run --rm \
    -v "${root}/apps/web:/app" \
    -w /app \
    -e "PUBLIC_API_URL=${public_api_url}" \
    node:20-alpine \
    sh -c "npm ci && npm run build"
}
