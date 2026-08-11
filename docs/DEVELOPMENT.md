# Development

## NUI

The frontend source is in `web/src`. The `web/dist` directory is generated output and is intentionally not committed to the development branch; CI verifies that it can be reproduced from source.

For frontend development:

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
- `locales/` — translations
- `sql/` — database schema/bootstrap
- `web/` — React/TypeScript NUI source

## Contribution rules

Keep privileged decisions on the server, avoid introducing hardcoded private identifiers, and document migrations or behavior changes in pull requests.
