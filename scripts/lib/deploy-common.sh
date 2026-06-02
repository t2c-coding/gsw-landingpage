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

# Fail fast when DOMAIN is proxied and DNS-01 token is not configured.
check_acme_dns() {
  local domain="$1"
  if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
    return 0
  fi

  if ! command -v dig >/dev/null 2>&1; then
    log "Warning: dig not installed; skipping DNS preflight (install dnsutils)"
    return 0
  fi

  local ip
  while read -r ip; do
    [ -z "$ip" ] && continue
    if is_cloudflare_proxy_ip "$ip"; then
      log "ERROR: ${domain} resolves to Cloudflare proxy (${ip})"
      log "Let's Encrypt cannot complete HTTP/TLS challenges on your VM."
      log ""
      log "Fix (pick one):"
      log "  1. Cloudflare DNS → disable proxy (grey cloud) for ${domain}, wait ~2 min, redeploy"
      log "  2. Set CLOUDFLARE_API_TOKEN in .env (Zone.DNS Edit) for DNS-01 ACME — proxy can stay on"
      log ""
      log "See README.md → TLS / Cloudflare troubleshooting"
      return 1
    fi
  done < <(dig +short A "$domain" AAAA "$domain" 2>/dev/null)

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
