#!/usr/bin/env bash
set -euo pipefail
UP_PATH="${1:-examples/typescript/clients/fetch}"
UP_SHA="${2:-unknown}"

# We keep a mirror for reference
mkdir -p vendor/upstream

# 1) Map the upstream example code into template root, preserving full structure.
#    Copy all files (source, configs, assets) so the starter mirrors upstream.
mkdir -p template
rsync -a --delete vendor/upstream/ template/

# Refresh NOTICE with the commit we synced from
cat > NOTICE <<EOF
This package includes portions derived from coinbase/x402 (${UP_PATH}), Apache-2.0,
commit ${UP_SHA}. See LICENSE and upstream LICENSE notices.
EOF

# Remove legacy src/ if present (we now mirror upstream at template root)
rm -rf template/src || true

echo "Sanitization complete."

# Cleanup transient directories so they don't get committed
rm -rf vendor/upstream || true
rm -rf upstream || true