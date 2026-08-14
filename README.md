<div align="center">

# 👑 ArmasVIP

### Professional VIP Weapon Management for FiveM Roleplay Servers

**Persistent ownership · Weapon Studio · Animated runtime skins · ES/EN · Open source**

![Version](https://img.shields.io/badge/version-2.4.0-orange)
![FiveM](https://img.shields.io/badge/platform-FiveM-blue)
![Roleplay](https://img.shields.io/badge/server-Roleplay-purple)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Languages](https://img.shields.io/badge/languages-ES%20%7C%20EN-brightgreen)
![Inventory](https://img.shields.io/badge/inventory-ox__inventory-lightgrey)

**Qbox · QBCore · ESX · Standalone identity fallback**

</div>

## Overview

**ArmasVIP is an open-source VIP weapon management script for FiveM roleplay servers.** Staff can assign persistent VIP weapons while ownership, recovery, cosmetics and validation remain server-authoritative.

Version 2.4 introduces **Weapon Studio**: players can preview and equip persistent skins from `/misarmasvip`, including bundled animated skins rendered at runtime. The bundled skin system does not require Blender, custom weapon models or external image hosting.

## Highlights

- Persistent SQL-backed VIP weapon ownership
- Personal `/misarmasvip` arsenal and validated recovery
- ACE-protected administration
- Per-instance VIP metadata and anti-duplication checks
- Non-transferable VIP weapon protection through `ox_inventory` hooks
- Persistent tints/camos and skin unlocks per grant
- **Weapon Studio skin selector with preview-before-equip**
- **Bundled static skins:** Carbon and Royal Gold
- **Bundled animated skins:** Galaxy Flow, Inferno and Electric Pulse
- Runtime skin renderer using FiveM DUI/runtime textures
- VIP weapon inspect animation (`I` by default)
- Administrator skin-unlock manager (`/armasvipskins`)
- Qbox, QBCore, ESX and Rockstar-license identity support
- Full Spanish and English localization
- React + TypeScript NUI source included
- Automated runtime-only GitHub Release packages

## Weapon Studio

Open `/misarmasvip`, select a VIP weapon and enter **Weapon Studio**. A skin can be previewed before it is equipped. The server validates the grant, compatibility and unlock before saving the selected skin.

Bundled skins are generated inside the resource:

```text
Original
Carbon
Royal Gold
Galaxy Flow      [Animated]
Inferno          [Animated]
Electric Pulse   [Animated]
```

Server owners can choose which skins are unlocked by default in `Config.Skins.DefaultUnlocked`. Administrators can grant/remove skins per VIP weapon with `/armasvipskins`.

### Runtime-skin scope

Weapon Studio 2.4 uses GTA texture replacement through FiveM runtime textures. The selected skin is persistent and automatically reapplied to the player's equipped VIP weapon. **Runtime replacements are client-local rendering state; ArmasVIP does not claim per-instance remote-player skin synchronization when multiple players use the same GTA texture at the same time.**

This limitation is documented intentionally rather than hidden. See [Weapon Studio](docs/WEAPON_STUDIO.md) for the architecture and extension options.

## Download & install

> **Server owners do not need Node.js, npm, Blender or a frontend build step.**

For stable versions, download the versioned `ArmasVIP-vX.Y.Z.zip` asset from **GitHub Releases**. The official asset already contains the compiled NUI.

```text
armasvip/
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

Do **not** use GitHub's automatically generated `Source code (zip)` as the normal server package. It contains development files and NUI source.

### Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`
- Qbox, QBCore or ESX are optional identity integrations

### server.cfg

```cfg
# Español
setr ox:locale es

# Permission
add_ace group.admin armasvip.admin allow

ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure armasvip
```

Use `setr ox:locale en` for English.

Full setup: **[Installation Guide](docs/INSTALLATION.md)**.

## Commands

| Command | Purpose |
|---|---|
| `/armasvip` | Assign VIP weapons |
| `/misarmasvip` | Personal arsenal and Weapon Studio |
| `/armasvipgestionar` | Manage persistent VIP grants |
| `/armasvipskins` | Administer skin unlocks per grant |
| `/vipinspect` | Inspect the currently equipped VIP weapon |

`vipinspect` is mapped to **I** by default and can be changed in `Config.Skins.Inspect`.

## Security model

The NUI never grants ownership or cosmetics. The server validates player identity, grant ownership, skin existence, weapon compatibility and unlock state before persisting a selection. VIP ownership, anti-duplication and transfer protection remain server-authoritative.

See **[Security Model](docs/SECURITY.md)**.

## Development

Normal installation requires no build tools. Contributors modifying the React/TypeScript NUI can build it from source; tagged releases build the NUI automatically in GitHub Actions.

See **[Development Guide](docs/DEVELOPMENT.md)**.

## Documentation

- [Installation](docs/INSTALLATION.md)
- [Configuration](docs/CONFIGURATION.md)
- [Weapon Studio](docs/WEAPON_STUDIO.md)
- [Security](docs/SECURITY.md)
- [Development](docs/DEVELOPMENT.md)
- [Changelog](CHANGELOG.md)
- [Contributing](CONTRIBUTING.md)

## License

ArmasVIP is released under the **GNU General Public License v3.0 (GPL-3.0)**.

---

<div align="center">

**ArmasVIP — persistent VIP ownership and runtime weapon customization for FiveM roleplay servers.**

</div>
