#!/usr/bin/env bash
# env helpers

myip() {
  ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '^127\.' | head -n1
}

gateway() {
  ip route 2>/dev/null | awk '/^default/{print $3; exit}' | grep . \
    || route -n 2>/dev/null | awk '$1=="0.0.0.0"{print $2; exit}'
}

tcpup() { timeout 1 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null; }

fetch() { curl -fsSL --max-time "${2:-15}" "$1" 2>/dev/null; }

lootdir() { mkdir -p "$ROOT_DIR/loot"; printf '%s' "$ROOT_DIR/loot"; }

deps_report() {
  local miss=""
  for b in curl nmap dig whois python3 jq openssl aircrack-ng qrencode; do
    command -v "$b" >/dev/null 2>&1 || miss="$miss $b"
  done
  [ -z "$miss" ] && { ok "all core deps present"; return 0; }
  err "missing:$miss"
  info "run ./install.sh"
}
