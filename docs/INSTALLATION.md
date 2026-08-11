# Installation

## Recommended installation: GitHub Release

Server owners should download the versioned `ArmasVIP-vX.Y.Z.zip` asset attached to a GitHub Release. The release package already contains the compiled NUI and does **not** require Node.js.

Do not confuse the official release asset with GitHub's automatic `Source code (zip)` archive. Source archives are for development and include repository-only files.

## Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`
- Optional identity integration: Qbox, QBCore or ESX

## Language

Choose one locale in `server.cfg`:

```cfg
setr ox:locale es
```

or:

```cfg
setr ox:locale en
```

## Startup order

```cfg
ensure oxmysql
ensure ox_lib
# ensure your framework here when applicable
ensure ox_inventory
ensure armasvip
```

## ACE permission

Administrative actions use `armasvip.admin`:

```cfg
add_ace group.admin armasvip.admin allow
```

Or use a dedicated group:

```cfg
add_ace group.armasvip armasvip.admin allow
add_principal identifier.license:YOUR_LICENSE group.armasvip
```

Replace the example identifier only in your private `server.cfg`. Never commit real player identifiers to a public repository.

## Database

Import `sql/install.sql` if you prefer manual schema installation. ArmasVIP also includes safe bootstrap/migration logic for its required tables.

## Commands

- `/armasvip` — administrative assignment UI (ACE protected)
- `/misarmasvip` — personal VIP arsenal
- `/armasvipgestionar` — persistent grant management

## Development installation

Only developers working on the NUI need Node.js 20+:

```bash
cd armasvip/web
npm install
npm run lint
npm run build
```
