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
