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
  - Resolve latest `x402-fetch` version from npm (best-effort).
  - Mirror files into `vendor/upstream/` (transient; ignored in git and cleaned up).
  - Run `scripts/sanitize.sh` to:
    - Copy all files from `vendor/upstream/` into `template/` (root of the template), preserving structure.
    - Remove any legacy `template/src/` directory.
    - Refresh `NOTICE` with the upstream commit and clean up `vendor/` and `upstream/` directories.
  - Inject the resolved `x402-fetch` version into `template/package.json` (replacing any workspace reference).
  - Open a PR with the changes using `peter-evans/create-pull-request`.

Notes:

- If `npm view x402-fetch version` fails, the workflow falls back to `0.0.0` and will skip injecting the dependency until it is available.
- The template mirrors the upstream example at the template root (no `src/` in the template). Your generated app runs from its root.

### Local development of this starter

```bash
# run the sanitize/mapping script locally (after an upstream sync or manual vendor update)
scripts/sanitize.sh examples/typescript/clients/fetch <commit-sha>
```

Key files:

- `template/` – shipped starter template; mirrors upstream example at root
- `vendor/upstream/` – transient mirror used during sync (gitignored and cleaned)
- `.github/workflows/sync.yml` – sync/PR workflow
- `scripts/sanitize.sh` – maps upstream example into `template/` (root)
- `bin/create.js` – CLI that scaffolds a new project from `template/`

### Releasing this starter to npm (optional)

- The `Release` workflow publishes on pushes to `main`.
- Requires `NPM_TOKEN` secret configured in the repo.

### License and attribution

Apache-2.0. Portions are derived from `coinbase/x402` (see `NOTICE`, `LICENSE`, and upstream notices).
