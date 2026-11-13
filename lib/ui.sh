#!/usr/bin/env bash
# colors + chrome
if [ -t 1 ]; then
  R=$'\e[0m'; B=$'\e[1m'; DIM=$'\e[2m'
  RED=$'\e[38;5;203m'; GRN=$'\e[38;5;114m'; YEL=$'\e[38;5;221m'
  BLU=$'\e[38;5;111m'; MAG=$'\e[38;5;176m'; CYN=$'\e[38;5;116m'; GRY=$'\e[38;5;242m'
else
  R=; B=; DIM=; RED=; GRN=; YEL=; BLU=; MAG=; CYN=; GRY=
fi

ok()   { printf '%s\n' "${GRN}[+]${R} $*"; }
warn() { printf '%s\n' "${YEL}[!]${R} $*"; }
err()  { printf '%s\n' "${RED}[x]${R} $*"; }
info() { printf '%s\n' "${CYN}[i]${R} $*"; }

ask() {
  local p="$1" v
  printf '%s' "${BLU}?${R} ${p}: " >&2
  read -r v
  printf '%s' "$v"
}

askdef() {
  local p="$1" d="$2" v
  printf '%s' "${BLU}?${R} ${p} ${DIM}[${d}]${R}: " >&2
  read -r v
  printf '%s' "${v:-$d}"
}

pause() { printf '\n%s' "${DIM}— enter —${R}"; read -r _; }

banner() {
  printf '%s\n' "${MAG}${B}"
  printf '%s\n' '  ┌─────────────────────────────────────────┐'
  printf '%s\n' '  │  iSH H4CK   v1.0   alpine/x86           │'
  printf '%s\n' '  │  recon · creds · crack · osint · wa     │'
  printf '%s\n' '  └─────────────────────────────────────────┘'
  printf '%s\n' "${R}"
}
