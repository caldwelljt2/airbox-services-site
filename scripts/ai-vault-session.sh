#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SLUG="${PROJECT_SLUG:-airbox-services-site}"
DEFAULT_VAULT="$HOME/AI-Vault"

bold() { printf "\033[1m%s\033[0m\n" "$*"; }
info() { printf "[session] %s\n" "$*"; }
err()  { printf "[session][error] %s\n" "$*" >&2; }

locate_vault() {
  if [ -n "${AI_VAULT_DIR:-}" ] && [ -d "$AI_VAULT_DIR" ] && [ -x "$AI_VAULT_DIR/bin/vault-new-session" ]; then
    printf "%s\n" "$AI_VAULT_DIR"; return 0
  fi
  if [ -f "$REPO_DIR/.ai-vault" ]; then
    local p
    p="$(head -n1 "$REPO_DIR/.ai-vault" | tr -d '\r\n')"
    if [ -n "$p" ] && [ -d "$p" ] && [ -x "$p/bin/vault-new-session" ]; then
      printf "%s\n" "$p"; return 0
    fi
  fi
  printf "Path to AI-Vault (default: %s): " "$DEFAULT_VAULT" >&2
  read -r inp || inp=""
  local p="${inp:-$DEFAULT_VAULT}"
  if [ ! -x "$p/bin/vault-new-session" ]; then
    err "Invalid AI-Vault at '$p' (missing bin/vault-new-session)"
    exit 2
  fi
  printf "%s\n" "$p" > "$REPO_DIR/.ai-vault"
  printf "%s\n" "$p"
}

VAULT_DIR="$(locate_vault)"; export AI_VAULT_DIR="$VAULT_DIR"
PROJ_DIR="$VAULT_DIR/projects/$SLUG"
LINK_PATH="$REPO_DIR/external-docs.session"

mkdir -p "$PROJ_DIR/TRANSCRIPTS" "$PROJ_DIR/ATTACH"

# Ensure the ephemeral symlink is ignored from version control
mkdir -p "$REPO_DIR/.git/info" || true
grep -qxF "/external-docs.session" "$REPO_DIR/.git/info/exclude" 2>/dev/null || echo "/external-docs.session" >> "$REPO_DIR/.git/info/exclude"

cleanup() {
  info "Ending session: cleaning up ephemeral symlink"
  rm -f "$LINK_PATH" 2>/dev/null || true
  info "Syncing AI-Vault changes"
  "$VAULT_DIR/bin/vault-sync" "Session sync for $SLUG" || true
  if git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    read -r -p "Push website repo changes too? [y/N] " ans || ans=""
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      (cd "$REPO_DIR" && git add -A && git commit -m "Website session updates ($(date -u +%Y-%m-%dT%H:%M:%SZ))" || true && git push || true) || true
    fi
  fi
}
trap cleanup EXIT

ln -sfn "$PROJ_DIR" "$LINK_PATH"
info "Ephemeral link ready: $LINK_PATH -> $PROJ_DIR"

# Start or append transcript summary and begin terminal capture
TRANS_FILE="$("$VAULT_DIR/bin/vault-new-session" "$SLUG" no-open)"
info "Transcript: $TRANS_FILE"
"$VAULT_DIR/bin/vault-append-transcript" "$SLUG" "Started session from website repo: $REPO_DIR (slug=$SLUG). Ephemeral link at $LINK_PATH."

info "Launching terminal recording (type 'exit' to stop)"
"$VAULT_DIR/bin/vault-start-term-log" "$SLUG"

info "Session finished. Transcript and logs saved under vault project."

