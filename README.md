# ish-h4ck

A recon / credential / cracking toolkit built **for the constraints of iSH**,
not copied from a Kali box.

## Install

    apk update
    git clone https://github.com/itzzEIias/ish-h4ck ~/ish-h4ck
    cd ~/ish-h4ck && chmod +x ish install.sh
    ./install.sh
    ./ish

## iOS settings you need first

- Settings → Privacy → **Local Network** → enable iSH (LAN sweep is dead without it)
- Keep the app foregrounded during long jobs; `tmux new -s w` if you must switch

## Module notes

**1 · WiFi** — `LAN sweep` walks `/24` on ports 80/443/22/445/62078/8080 with
`/dev/tcp`, ~4 min. `router default creds` fires the shipped list at your gateway
(basic auth only). `WPS PIN` derives a candidate from the BSSID. `crack a .cap`
runs `aircrack-ng` against a capture you made on real hardware. No deauth — the
radio isn't exposed.

**2 · WhatsApp** — `is a number registered?` is the ban check; it walks cc lengths
3→2→1 against the `v2/exist` endpoint. `OTP flood` posts to `v2/code` at 6s
intervals; ~25–40 requests produces the "too many attempts" lockout. The
**perm ban playbook** (option 4) is the ordered procedure — flood, then report
wave, then escalation. Read it before you start; the order matters more than the
volume.

**3 · OSINT** — username enumeration across nine sites (200 = taken, 403 =
inconclusive), breach check, IP intel + reverse DNS + top-port scan, domain intel
via `crt.sh` subdomain pull.

**4 · Network** — everything is `-sT -Pn`. SYN scan will not work here. TLS cert
pull via `openssl s_client`.

**5 · Cracking** — pure-Python dictionary attacks for md5/sha1/sha256/sha512 and
zip. Slow but correct under emulation. `wordlist gen` does base-word + suffix
mutation.

**6 · Phishing** — the cloner rewrites relative asset paths so the page renders
offline. Static, so forms need a webhook target. Remember: nothing you serve from
iSH is reachable from your LAN — push it to Pages/Netlify.

**7 · Utilities** — QR, shortener, pwgen, encoding, speedtest, temp mail.
