#!/usr/bin/env bash

m_crack() {
  while :; do
    printf '\n%s\n' "${B}${MAG}Cracking${R}"
    printf ' 1) hash dict attack\n 2) identify a hash\n 3) zip password\n 4) wordlist gen\n 0) back\n'
    printf '%s' "${BLU}crack>${R}"; read -r c
    case "$c" in
      1) cr_hash; pause ;; 2) cr_id; pause ;; 3) cr_zip; pause ;; 4) cr_gen; pause ;; 0) return ;;
    esac
  done
}

cr_hash() {
  local h wl
  h=$(ask "hash")
  wl=$(askdef "wordlist" "$ROOT_DIR/wordlists/pwdsmall.txt")
  python3 - "$h" "$wl" <<'PY'
import hashlib, sys
h, wl = sys.argv[1].strip().lower(), sys.argv[2]
algos = {32: 'md5', 40: 'sha1', 64: 'sha256', 128: 'sha512'}
name = algos.get(len(h))
if not name: sys.exit("unsupported length")
for w in open(wl, errors='ignore'):
    w = w.rstrip('\n')
    if hashlib.new(name, w.encode()).hexdigest() == h:
        print("[+] cracked:", w); sys.exit(0)
print("[x] not in wordlist")
PY
  info "pure python — 100k words takes a few minutes under emulation"
}

cr_id() {
  local h
  h=$(ask "hash")
  case ${#h} in
    32) echo "md5 / ntlm" ;; 40) echo "sha1" ;; 64) echo "sha256" ;;
    128) echo "sha512" ;; *) echo "unknown / salted" ;;
  esac
}

cr_zip() {
  local z wl
  z=$(ask "zip path"); wl=$(askdef "wordlist" "$ROOT_DIR/wordlists/pwdsmall.txt")
  python3 - "$z" "$wl" <<'PY'
import sys, zipfile
z, wl = sys.argv[1], sys.argv[2]
zf = zipfile.ZipFile(z)
for w in open(wl, errors='ignore'):
    w = w.rstrip('\n')
    try:
        zf.read(zf.namelist()[0], pwd=w.encode()); print("[+] password:", w); break
    except Exception: pass
else: print("[x] not found")
PY
}

cr_gen() {
  local base min max
  base=$(ask "base words (comma separated)")
  min=$(askdef "min length" "6"); max=$(askdef "max length" "10")
  python3 - "$base" "$min" "$max" <<'PY'
import sys, itertools
base, lo, hi = sys.argv[1].split(','), int(sys.argv[2]), int(sys.argv[3])
suf = ['', '1', '12', '123', '!', '2024', '2025', '2026', '01']
for b in base:
    for s in suf:
        for v in [b.capitalize(), b.upper(), b]:
            w = v + s
            if lo <= len(w) <= hi: print(w)
PY
}
