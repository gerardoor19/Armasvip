<div align="center">

# 👑 ArmasVIP

### Persistent VIP Weapon Ownership for FiveM

**Open-source, server-authoritative VIP weapon grants with persistent ownership, protected recovery and a dedicated NUI arsenal.**

![Version](https://img.shields.io/badge/version-2.3.0-orange)
![FiveM](https://img.shields.io/badge/platform-FiveM-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Inventory](https://img.shields.io/badge/inventory-ox__inventory-lightgrey)
![Database](https://img.shields.io/badge/database-oxmysql-lightgrey)
![Source](https://img.shields.io/badge/source-open-brightgreen)

**Qbox · QBCore · ESX · Standalone identity fallback**

</div>

## Overview

ArmasVIP separates **persistent ownership** from the temporary weapon item stored in `ox_inventory`. An authorized administrator assigns a specific VIP weapon to a player, creating a persistent grant. If the physical item is lost, the grant remains and recovery is allowed only after server-side validation.

```text
Authorized admin
      │
      ▼
Create VIP grant
      │
      ▼
Persistent SQL ownership
      │
      ▼
Validated VIP inventory instance
      │
      ▼
Player arsenal / recovery / cosmetics
```

## Features

- Persistent SQL-backed VIP weapon grants
- ACE-protected administrative UI
- Personal `/misarmasvip` arsenal
- Anti-duplication recovery validation
- Per-instance VIP metadata rather than global weapon overrides
- Transfer protection through `ox_inventory` hooks
- VIP durability handling without changing normal copies of the same weapon
- Persistent tint/camo entitlement validation
- Qbox, QBCore, ESX and Rockstar-license identity support
- React + TypeScript NUI with source included
- Full source code available in this repository

## Showcase

### Player VIP Arsenal

<img width="100%" alt="ArmasVIP player arsenal" src="https://github.com/user-attachments/assets/7832c509-7bc8-4b1b-9c66-8e3a4541e611" />

### Administrative Assignment

<img width="100%" alt="ArmasVIP administrative weapon assignment" src="https://github.com/user-attachments/assets/06b94175-d97b-4f74-8f1f-fe27796cb70c" />

### Persistent Customization

<img width="100%" alt="ArmasVIP customization" src="https://github.com/user-attachments/assets/b92798b8-cfb7-4e08-97b7-2d749fdbb420" />

## Security model

The server is authoritative. A hidden button or NUI state is never considered authorization. Sensitive operations validate the relevant ACE permission, player identity, grant ownership, weapon association and current inventory state on the server.

VIP behavior applies only to inventory instances carrying valid VIP metadata backed by a persistent grant. A normal copy of the same `WEAPON_*` remains a normal weapon.

See [docs/SECURITY.md](docs/SECURITY.md).

## Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`

## Installation

Clone the repository into your resources directory:

```bash
git clone https://github.com/gerardoor19/Armasvip.git armasvip
```

Build the NUI before starting the resource:

```bash
cd armasvip/web
npm install
npm run build
```

Recommended `server.cfg` order:

```cfg
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure armasvip
```

Grant the administrative ACE to the appropriate server group:

```cfg
add_ace group.admin armasvip.admin allow
```

Full instructions: **[Installation Guide](docs/INSTALLATION.md)**.

## Commands

| Command | Purpose |
|---|---|
| `/armasvip` | Administrative VIP weapon assignment |
| `/misarmasvip` | Player VIP arsenal |
| `/armasvipgestionar` | Manage persistent grants |

## Development

The editable NUI source is under `web/src`. `web/dist` is generated output and is not committed to the development branch.

```bash
cd web
npm install
npm run lint
npm run build
```

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Documentation

- [Installation](docs/INSTALLATION.md)
- [Configuration](docs/CONFIGURATION.md)
- [Security](docs/SECURITY.md)
- [Development](docs/DEVELOPMENT.md)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)

## License

ArmasVIP is released under the **GNU General Public License v3.0 (GPL-3.0)**. You may use, study, modify and redistribute the project under the terms of that license.

---

<div align="center">

**ArmasVIP — persistent ownership, server authority, open source.**

</div>
