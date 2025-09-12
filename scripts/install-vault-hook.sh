#!/usr/bin/env bash
set -euo pipefail

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/post-commit"
mkdir -p "$HOOK_DIR"

cat > "$HOOK_FILE" <<'EOF'
#!/usr/bin/env bash
# Post-commit: check ops version and optionally sync the private vault
VAULT_BIN="$HOME/AI-Vault/bin"
REPO_DIR="$(pwd)"

if [ -x "$VAULT_BIN/vault-check-version" ]; then
  "$VAULT_BIN/vault-check-version" "$REPO_DIR" || true
fi

# Auto-push only if explicitly enabled
if [ "${VAULT_AUTO_PUSH:-0}" = "1" ] && [ -x "$VAULT_BIN/vault-sync" ]; then
  "$VAULT_BIN/vault-sync" "sync after commit: $(basename "$REPO_DIR")" || true
else
  echo "[vault] Skipping auto-push. Set VAULT_AUTO_PUSH=1 to enable."
fi
EOF

chmod +x "$HOOK_FILE"
echo "Installed post-commit hook at $HOOK_FILE"

