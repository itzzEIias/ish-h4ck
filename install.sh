#!/usr/bin/env bash
# iSH dependency installer. Tolerant: never aborts on a missing package.
set -u
[ "$(uname -m)" = "x86_64" ] || echo "[!] not x86 — this is built for iSH"

PKGS="bash curl wget nmap nmap-scripts bind-tools whois openssl jq git python3 \
qrencode fcrackzip netcat-openbsd tcpdump tmux aircrack-ng steghide coreutils file"

echo "[*] apk update"
apk update 2>&1 | tail -n 2

for p in $PKGS; do
  printf '  %-18s' "$p"
  if apk add --no-cache "$p" >/dev/null 2>&1; then echo "ok"; else echo "skip"; fi
done

echo
echo "[*] done. 'skip' entries are optional or unavailable on your Alpine pin."
echo "[*] run: ./ish"
