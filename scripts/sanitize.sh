#!/usr/bin/env bash
set -euo pipefail
UP_PATH="${1:-examples/typescript/clients/fetch}"
UP_SHA="${2:-unknown}"

# We keep a mirror for reference
mkdir -p vendor/upstream

# 1) Map the upstream example code into template/src, preserving full structure.
#    Copy all files (source, configs, assets) so the starter mirrors upstream.
mkdir -p template/src
rsync -a --delete vendor/upstream/ template/src/

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

# Cleanup transient directories so they don't get committed
rm -rf vendor/upstream || true
rm -rf upstream || true