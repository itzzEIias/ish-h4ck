#!/usr/bin/env bash

m_tools() {
  while :; do
    printf '\n%s\n' "${B}${MAG}Utilities${R}"
    printf ' 1) QR code\n 2) shorten URL\n 3) password gen\n 4) base64/url encode\n 5) speedtest\n 6) temp mail\n 0) back\n'
    printf '%s' "${BLU}tools>${R}"; read -r c
    case "$c" in
      1) tl_qr; pause ;; 2) tl_short; pause ;; 3) tl_pw; pause ;;
      4) tl_enc; pause ;; 5) tl_speed; pause ;; 6) tl_mail; pause ;; 0) return ;;
    esac
  done
}

tl_qr() { local t; t=$(ask "text/URL"); qrencode -t ANSIUTF8 "$t"; }

tl_short() {
  local u
  u=$(ask "URL")
  fetch "https://tinyurl.com/api-create.php?url=$u" 12; echo
}

tl_pw() {
  local n
  n=$(askdef "length" "20")
  LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*_-' < /dev/urandom | head -c "$n"; echo
}

tl_enc() {
  local m v
  m=$(ask "b64e / b64d / urle / urld"); v=$(ask "value")
  case "$m" in
    b64e) printf '%s' "$v" | base64 -w0; echo ;;
    b64d) printf '%s' "$v" | base64 -d 2>/dev/null; echo ;;
    urle) printf '%s' "$v" | jq -sRr @uri ;;
    urld) printf '%s' "$v" | sed 's/%\([0-9A-Fa-f]\{2\}\)/\\x\1/g' | xargs -0 printf ;;
  esac
}

tl_speed() {
  info "download test (25MB from Cloudflare)"
  curl -o /dev/null -s -w '  %{speed_download} B/s\n' \
    "https://speed.cloudflare.com/__down?bytes=25000000"
}

tl_mail() {
  info "1secmail"
  curl -s --max-time 12 "https://www.1secmail.com/api/v1/?action=getDomainList" | jq -r '.[0:5][]'
  local u d
  u=$(ask "inbox name"); d=$(ask "domain from above")
  curl -s --max-time 12 "https://www.1secmail.com/api/v1/?action=getMessages&login=$u&domain=$d" | jq .
  info "address: $u@$d"
}
