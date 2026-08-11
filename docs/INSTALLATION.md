# Installation

## Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`
- Node.js 20+ to build the NUI from source
- Optional identity integration: Qbox, QBCore or ESX

## Install

Clone or download this repository into your FiveM resources directory and keep the resource folder named `armasvip`.

Build the NUI:

```bash
cd armasvip/web
npm install
npm run build
```

Recommended startup order:

```cfg
ensure oxmysql
ensure ox_lib
# ensure your framework here when applicable
ensure ox_inventory
ensure armasvip
```

## ACE permission

Administrative actions use the `armasvip.admin` ACE.

```cfg
add_ace group.admin armasvip.admin allow
```

Or assign it to a dedicated group:

```cfg
add_ace group.armasvip armasvip.admin allow
add_principal identifier.license:YOUR_LICENSE group.armasvip
```

Replace the example identifier in your private `server.cfg`. Do not commit real player identifiers to a public repository.

## Database

Import `sql/install.sql` if you prefer manual schema installation. The resource also contains migration/bootstrap logic for its required tables.

## Commands

- `/armasvip` — administrative assignment UI (ACE protected)
- `/misarmasvip` — personal VIP arsenal
- `/armasvipgestionar` — grant management

## Updating the NUI

After changing files under `web/src`, rebuild before restarting the resource:

```bash
cd web
npm run build
```

The generated `web/dist` directory is intentionally excluded from the development branch.
