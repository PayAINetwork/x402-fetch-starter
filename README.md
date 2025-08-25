## x402 Fetch Starter

Starter and sync wrapper around the upstream example at [coinbase/x402 → examples/typescript/clients/fetch](https://github.com/coinbase/x402/tree/main/examples/typescript/clients/fetch). This repo provides:

- **Scaffold CLI**: quickly create a runnable x402 client template using `x402-fetch`.
- **Auto-sync**: keeps the template’s example code aligned with the upstream example via GitHub Actions and opens a PR with changes.

### Requirements

- **Node.js**: 18 or newer
- **GitHub Actions** enabled in your fork/repo

### Create a new app from the template

Use any of the following:

```bash
# npm
npm exec @payai/x402-fetch-starter -- my-x402-app

# pnpm
pnpm dlx @payai/x402-fetch-starter my-x402-app

# bun
bunx @payai/x402-fetch-starter my-x402-app
```

Then inside your new app:

```bash
cp .env-local .env
npm i
npm run dev
```

### How sync works

- Workflow: `.github/workflows/sync.yml`
- Triggered hourly (cron) and on manual dispatch.
- Steps (high level):
  - Sparse clone upstream `coinbase/x402` and restrict to `examples/typescript/clients/fetch`.
  - Resolve latest `x402-fetch` version from npm (best-effort) and, if available, inject it into `template/package.json`.
  - Mirror files into `vendor/upstream/`.
  - Run `scripts/sanitize.sh` to:
    - Copy `.ts`/`.tsx` from `vendor/upstream/` into `template/src/` (preserves relative structure).
    - Copy upstream README to `template/docs/upstream/` for reference.
    - Refresh `NOTICE` with the upstream commit.
  - Open a PR with the changes using `peter-evans/create-pull-request`.

Notes:

- If `npm view x402-fetch version` fails, the workflow falls back to `0.0.0` and will skip injecting the dependency until it is available.
- The template includes a minimal fallback `template/src/index.ts`. On sync, upstream example files will overwrite matching paths under `template/src/`.

### Local development of this starter

```bash
# run the sanitize/mapping script locally (after an upstream sync or manual vendor update)
scripts/sanitize.sh examples/typescript/clients/fetch <commit-sha>
```

Key files:

- `template/` – shipped starter template (package.json, tsconfig, src, docs)
- `vendor/upstream/` – mirrored upstream example (not published)
- `.github/workflows/sync.yml` – sync/PR workflow
- `scripts/sanitize.sh` – maps upstream example into `template/src/`
- `bin/create.js` – CLI that scaffolds a new project from `template/`

### Releasing this starter to npm (optional)

- The `Release` workflow publishes on pushes to `main`.
- Requires `NPM_TOKEN` secret configured in the repo.

### License and attribution

Apache-2.0. Portions are derived from `coinbase/x402` (see `NOTICE`, `LICENSE`, and upstream notices).
