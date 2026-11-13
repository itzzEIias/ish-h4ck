#!/usr/bin/env bash

m_osint() {
  while :; do
    printf '\n%s\n' "${B}${MAG}OSINT${R}"
    printf ' 1) username across sites\n 2) email breach\n 3) IP intel\n 4) domain intel\n 0) back\n'
    printf '%s' "${BLU}osint>${R}"; read -r c
    case "$c" in
      1) os_user; pause ;; 2) os_email; pause ;;
      3) os_ip; pause ;; 4) os_dom; pause ;; 0) return ;;
    esac
  done
}

os_user() {
  local u code
  u=$(ask "username")
  for s in github.com reddit.com/ u/ instagram.com tiktok.com/@ twitter.com/ \
           pinterest.com medium.com/@ gitlab.com about.me/; do
    case "$s" in
      *u/|*/@|*/) host="${s}${u}" ;;
      *) host="${s}/${u}" ;;
    esac
    code=$(curl -s -o /dev/null -w '%{http_code}' -A "Mozilla/5.0" \
           --max-time 8 "https://$host")
    printf '  %-3s %s\n' "$code" "$host"
  done
  info "404 = free, 200 = taken, 403/999 = blocked (inconclusive)"
}

os_email() {
  local e
  e=$(ask "email")
  fetch "https://api.xposedornot.com/v1/check-email/$e" 20 | jq . 2>/dev/null \
    || err "no result"
}

os_ip() {
  local ip
  ip=$(ask "IP")
  fetch "https://ipinfo.io/$ip/json" 15 | jq -r '.ip,.city,.region,.country,.org' 2>/dev/null
  info "reverse DNS:"; dig +short -x "$ip"
  info "top ports:"; nmap -sT -Pn --top-ports 50 --open "$ip" 2>/dev/null | grep -E '^[0-9]'
}

os_dom() {
  local d
  d=$(ask "domain")
  info "whois:"; whois "$d" 2>/dev/null | grep -iE 'registrar:|creation|expiry' | head -5
  info "A / MX:"; dig +short "$d" A; dig +short "$d" MX
  info "subdomains (crt.sh):"
  fetch "https://crt.sh/?q=%25.$d&output=json" 30 \
    | jq -r '.[].name_value' 2>/dev/null | sort -u | head -30
}
