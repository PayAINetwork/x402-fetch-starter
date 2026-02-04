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

# Replace workspace:* dependencies with actual npm packages
# and ensure all @x402/* packages are present with correct versions
if [[ -f template/package.json ]]; then
  node - <<'NODE'
const fs = require('fs');
const path = 'template/package.json';
const json = JSON.parse(fs.readFileSync(path, 'utf8'));

// Get x402 version from root package.json config
let x402Version = '2.2.0';
try {
  const rootPkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  if (rootPkg.config && rootPkg.config.x402FetchVersion) {
    x402Version = rootPkg.config.x402FetchVersion;
  }
} catch (e) {}

const deps = json.dependencies || {};

// Remove workspace:* dependencies
for (const [name, version] of Object.entries(deps)) {
  if (typeof version === 'string' && version.startsWith('workspace:')) {
    delete deps[name];
  }
}

// Replace old x402-fetch with @x402/fetch
if (deps['x402-fetch']) {
  delete deps['x402-fetch'];
}

// Ensure all required @x402/* packages have correct versions
const x402Packages = ['@x402/fetch', '@x402/evm', '@x402/svm'];
for (const pkg of x402Packages) {
  if (deps[pkg] || pkg === '@x402/fetch') {
    deps[pkg] = '^' + x402Version;
  }
}

json.dependencies = deps;
fs.writeFileSync(path, JSON.stringify(json, null, 2));
console.log('Updated template/package.json: replaced workspace deps, using @x402/*@^' + x402Version);
NODE
fi

# Update imports in template files from x402-fetch to @x402/fetch
if [[ -f template/index.ts ]]; then
  sed -i.bak 's/from "x402-fetch"/from "@x402\/fetch"/g' template/index.ts && rm -f template/index.ts.bak
  sed -i.bak "s/from 'x402-fetch'/from '@x402\/fetch'/g" template/index.ts && rm -f template/index.ts.bak
fi

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