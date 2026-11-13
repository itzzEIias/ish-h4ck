#!/usr/bin/env bash

m_net() {
  while :; do
    printf '\n%s\n' "${B}${MAG}Network${R}"
    printf ' 1) port scan\n 2) DNS records\n 3) whois\n 4) HTTP headers\n 5) TLS cert\n 0) back\n'
    printf '%s' "${BLU}net>${R}"; read -r c
    case "$c" in
      1) net_scan; pause ;; 2) net_dns; pause ;; 3) net_whois; pause ;;
      4) net_hdr; pause ;; 5) net_tls; pause ;; 0) return ;;
    esac
  done
}

net_scan() {
  local h p
  h=$(ask "host")
  p=$(askdef "ports" "top100")
  case "$p" in
    top100) nmap -sT -Pn --top-ports 100 --open "$h" ;;
    *) nmap -sT -Pn -p "$p" --open "$h" ;;
  esac
  info "-sT only: SYN scan needs raw sockets iSH doesn't have"
}

net_dns() {
  local d
  d=$(ask "domain")
  for t in A AAAA MX TXT NS CNAME; do
    printf '%s\n' "${B}$t${R}"; dig +short "$d" "$t"
  done
}

net_whois() { whois "$(ask 'domain')" 2>/dev/null | head -40; }

net_hdr() {
  local u
  u=$(ask "URL")
  curl -sIL -A "Mozilla/5.0" --max-time 15 "$u" | head -30
  info "look for: missing HSTS / CSP / X-Frame-Options, server versions"
}

net_tls() {
  local h
  h=$(ask "host:port" )
  echo | openssl s_client -connect "$h" -servername "${h%%:*}" 2>/dev/null \
    | openssl x509 -noout -subject -issuer -dates
}
