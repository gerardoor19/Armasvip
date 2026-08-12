<div align="center">

# 👑 ArmasVIP

### Persistent VIP Weapon Ownership for FiveM

**Open-source · Server-authoritative · ES/EN · Install-ready GitHub Releases**

![Version](https://img.shields.io/badge/version-2.3.1-orange)
![FiveM](https://img.shields.io/badge/platform-FiveM-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Languages](https://img.shields.io/badge/languages-ES%20%7C%20EN-brightgreen)
![Inventory](https://img.shields.io/badge/inventory-ox__inventory-lightgrey)
![Database](https://img.shields.io/badge/database-oxmysql-lightgrey)

**Qbox · QBCore · ESX · Standalone identity fallback**

</div>

## Overview

ArmasVIP provides persistent VIP weapon ownership for FiveM. Authorized staff assign a specific VIP weapon to a player, creating a persistent server-side grant. The physical `ox_inventory` item can be lost or removed while the ownership grant remains available for validated recovery.

The project is fully open source and distributed through clean, versioned GitHub Release packages.

## Features

- Persistent SQL-backed VIP weapon grants
- ACE-protected administrative interface
- Personal `/misarmasvip` arsenal
- Anti-duplication recovery validation
- Per-instance VIP metadata instead of global weapon overrides
- Transfer protection through `ox_inventory` hooks
- VIP durability handling without modifying normal copies of the same weapon
- Persistent tint/camo entitlement validation
- Qbox, QBCore, ESX and Rockstar-license identity support
- React + TypeScript NUI source included in the repository
- Full Spanish and English localization
- Automated runtime-only GitHub Release packages

## Download & install

> **Server owners do not need Node.js, npm or a frontend build step.**

Download the versioned asset from **GitHub Releases**:

**`ArmasVIP-v2.3.1.zip`**

The official asset already includes the compiled NUI and is ready to place in your FiveM resources directory.

```text
ArmasVIP-v2.3.1.zip
└── armasvip/
    ├── fxmanifest.lua
    ├── LICENSE
    ├── client/
    ├── config/
    ├── locales/
    ├── server/
    ├── shared/
    ├── sql/
    └── web/dist/
```

Do **not** use GitHub's automatically generated `Source code (zip)` as the normal server package. Those archives contain the development repository, documentation and NUI source.

### Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`
- Qbox, QBCore or ESX are optional identity integrations

### server.cfg

Choose the language:

```cfg
# Español
setr ox:locale es
```

or:

```cfg
# English
setr ox:locale en
```

Grant administrative access and start the resources in order:

```cfg
add_ace group.admin armasvip.admin allow

ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure armasvip
```

Full setup: **[Installation Guide](docs/INSTALLATION.md)**.

## Languages

ArmasVIP includes complete Spanish and English localization. The selected `ox:locale` controls Lua menus, notifications, weapon categories, grant management, NUI labels, camos/tints and VIP item presentation.

## Showcase

### Player VIP Arsenal

<img width="100%" alt="ArmasVIP player arsenal" src="https://github.com/user-attachments/assets/7832c509-7bc8-4b1b-9c66-8e3a4541e611" />

### Administrative Assignment

<img width="100%" alt="ArmasVIP administrative weapon assignment" src="https://github.com/user-attachments/assets/06b94175-d97b-4f74-8f1f-fe27796cb70c" />

### Persistent Customization

<img width="100%" alt="ArmasVIP customization" src="https://github.com/user-attachments/assets/b92798b8-cfb7-4e08-97b7-2d749fdbb420" />

## Commands

| Command | Purpose |
|---|---|
| `/armasvip` | Administrative VIP weapon assignment |
| `/misarmasvip` | Personal VIP arsenal |
| `/armasvipgestionar` | Persistent grant management |

## Security model

The server is authoritative. NUI visibility is never treated as authorization. Sensitive operations validate ACE permissions, player identity, grant ownership, weapon association and inventory state server-side.

See **[Security Model](docs/SECURITY.md)**.

## Development

The repository contains the editable React/TypeScript NUI source. Building the frontend is required **only for contributors who modify the NUI**, never for normal server installation.

See **[Development Guide](docs/DEVELOPMENT.md)**.

## Documentation

- [Installation](docs/INSTALLATION.md)
- [Configuration](docs/CONFIGURATION.md)
- [Security](docs/SECURITY.md)
- [Development](docs/DEVELOPMENT.md)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)

## License

ArmasVIP is released under the **GNU General Public License v3.0 (GPL-3.0)**.

---

<div align="center">

**ArmasVIP — persistent ownership, server authority, open source.**

</div>
