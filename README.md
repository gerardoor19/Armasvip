<div align="center">

# 👑 ArmasVIP

### Persistent VIP Weapon Ownership for FiveM

**Open-source, server-authoritative VIP weapon grants with persistent ownership, protected recovery and a dedicated NUI arsenal.**

![Version](https://img.shields.io/badge/version-2.3.1-orange)
![FiveM](https://img.shields.io/badge/platform-FiveM-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Languages](https://img.shields.io/badge/languages-ES%20%7C%20EN-brightgreen)
![Inventory](https://img.shields.io/badge/inventory-ox__inventory-lightgrey)
![Database](https://img.shields.io/badge/database-oxmysql-lightgrey)

**Qbox · QBCore · ESX · Standalone identity fallback**

</div>

## Overview

ArmasVIP separates **persistent ownership** from the temporary weapon item stored in `ox_inventory`. Authorized staff assign a specific VIP weapon to a player, creating a persistent grant. If the physical item is lost, the grant remains and recovery is allowed only after server-side validation.

## Features

- Persistent SQL-backed VIP weapon grants
- ACE-protected administrative UI
- Personal `/misarmasvip` arsenal
- Anti-duplication recovery validation
- Per-instance VIP metadata instead of global weapon overrides
- Transfer protection through `ox_inventory` hooks
- VIP durability handling without changing normal copies of the same weapon
- Persistent tint/camo entitlement validation
- Qbox, QBCore, ESX and Rockstar-license identity support
- React + TypeScript NUI with source included
- Full Spanish and English localization
- Automated clean GitHub Release packages

## Languages

ArmasVIP ships with complete Spanish and English localization. Select the server language in `server.cfg`:

```cfg
# Spanish
setr ox:locale es
```

```cfg
# English
setr ox:locale en
```

Lua menus, notifications, categories, NUI labels, grant management and VIP item presentation follow the selected locale.

## Download

For a FiveM server, use the **versioned ZIP attached to GitHub Releases**:

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

The release asset is generated automatically and contains runtime files only. GitHub's automatic **Source code** archives are intended for development and include repository documentation and NUI source.

## Showcase

### Player VIP Arsenal

<img width="100%" alt="ArmasVIP player arsenal" src="https://github.com/user-attachments/assets/7832c509-7bc8-4b1b-9c66-8e3a4541e611" />

### Administrative Assignment

<img width="100%" alt="ArmasVIP administrative weapon assignment" src="https://github.com/user-attachments/assets/06b94175-d97b-4f74-8f1f-fe27796cb70c" />

### Persistent Customization

<img width="100%" alt="ArmasVIP customization" src="https://github.com/user-attachments/assets/b92798b8-cfb7-4e08-97b7-2d749fdbb420" />

## Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`

## Installation

1. Download the versioned `ArmasVIP-vX.Y.Z.zip` asset from **Releases**.
2. Extract the included `armasvip` folder into your FiveM resources directory.
3. Configure the language and administrative ACE.
4. Start dependencies before ArmasVIP.

```cfg
setr ox:locale en

add_ace group.admin armasvip.admin allow

ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure armasvip
```

See **[docs/INSTALLATION.md](docs/INSTALLATION.md)** for the complete setup.

## Development

Developers can clone the repository and build the NUI from source:

```bash
git clone https://github.com/gerardoor19/Armasvip.git armasvip
cd armasvip/web
npm install
npm run lint
npm run build
```

`web/dist` is generated output and is intentionally excluded from the development tree. Tagged releases build it automatically.

## Security model

The server is authoritative. NUI visibility is not authorization. Sensitive operations validate ACE permissions, player identity, grant ownership, weapon association and inventory state on the server.

See **[docs/SECURITY.md](docs/SECURITY.md)**.

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
