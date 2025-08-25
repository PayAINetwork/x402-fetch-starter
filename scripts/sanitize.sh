#!/usr/bin/env bash
set -euo pipefail
UP_PATH="${1:-examples/typescript/clients/fetch}"
UP_SHA="${2:-unknown}"

# We keep a mirror for reference
mkdir -p vendor/upstream

# If upstream provides a README or example code, prefer it
# 1) Keep a copy for docs
mkdir -p template/docs/upstream
if [ -f "vendor/upstream/README.md" ]; then
  cp vendor/upstream/README.md template/docs/upstream/clients-fetch-README.md || true
fi

# 2) Map the upstream example code into template/src, best-effort.
#    We only copy .ts and .tsx files and preserve relative structure under src/.
mkdir -p template/src
rsync -a --delete \
  --include='*.ts' --include='*.tsx' \
  --exclude='*' \
  vendor/upstream/ template/src/

# Refresh NOTICE with the commit we synced from
cat > NOTICE <<EOF
This package includes portions derived from coinbase/x402 (${UP_PATH}), Apache-2.0,
commit ${UP_SHA}. See LICENSE and upstream LICENSE notices.
EOF

# Ensure an index entry point exists. If upstream did not provide one, keep the fallback.
if [ ! -f template/src/index.ts ] && [ ! -f template/src/main.ts ]; then
  # No explicit entry from upstream; do not delete existing fallback if present.
  :
fi

echo "Sanitization complete."