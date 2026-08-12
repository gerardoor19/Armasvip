# Development

> This document is for contributors modifying the ArmasVIP source. Normal FiveM server installation uses the prebuilt GitHub Release ZIP and does **not** require Node.js or npm.

## NUI development

The editable frontend source is in `web/src`. The `web/dist` directory is generated output and is intentionally not committed to the repository; tagged releases build it automatically.

For contributors changing the NUI:

```bash
cd web
npm install
npm run lint
npm run build
```

Do not commit `web/node_modules`, `web/dist` or TypeScript `*.tsbuildinfo` files.

## Resource structure

- `server/` — authoritative grant, identity, permission and protection logic
- `client/` — FiveM/NUI integration and local VIP presentation behavior
- `shared/` — shared weapon data
- `config/` — public configuration
- `locales/` — Spanish and English translations
- `sql/` — database schema/bootstrap
- `web/` — React/TypeScript NUI source

## Validation

Pull requests should pass the repository CI checks before merge. The CI validates the NUI build and linting. Tagged release automation builds the runtime package separately and includes only the allow-listed FiveM runtime files.

## Contribution rules

Keep privileged decisions on the server, avoid hardcoded private identifiers, preserve the localization system for user-facing strings, and document migrations or behavior changes in pull requests.
