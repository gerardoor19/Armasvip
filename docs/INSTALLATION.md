# Installation

## Recommended installation: GitHub Release

For a normal FiveM server installation, download the versioned **ArmasVIP release asset** from GitHub Releases:

```text
ArmasVIP-vX.Y.Z.zip
```

The official release asset already includes the compiled NUI and Weapon Studio renderer. **Server owners do not need Node.js, npm, Blender or a frontend build step.**

Do not confuse the official release asset with GitHub's automatically generated `Source code (zip)` or `Source code (tar.gz)` archives. Those source archives are intended for developers.

## Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`
- Optional identity integration: Qbox, QBCore or ESX

## Install the resource

1. Download the versioned ArmasVIP ZIP from Releases.
2. Extract it.
3. Move the included `armasvip` folder into your FiveM resources directory.
4. Configure language and ACE permissions in `server.cfg`.
5. Start dependencies before `armasvip`.

Expected runtime structure:

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

## Language

Spanish:

```cfg
setr ox:locale es
```

English:

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

Administrative actions, including `/armasvipskins`, use `armasvip.admin`:

```cfg
add_ace group.admin armasvip.admin allow
```

Or use a dedicated group:

```cfg
add_ace group.armasvip armasvip.admin allow
add_principal identifier.license:YOUR_LICENSE group.armasvip
```

Replace the example identifier only in your private `server.cfg`. Never publish real player identifiers.

## Database

ArmasVIP automatically creates/migrates its required tables, including the Weapon Studio skin-state table. `sql/install.sql` is also included for manual installation.

## Weapon Studio

The bundled runtime skins work immediately for weapons listed in the texture map in `shared/skins.lua`. No external image hosting is used by default.

Default 2.4 configuration unlocks Original, Carbon, Royal Gold and Galaxy Flow for compatible grants. Change `Config.Skins.DefaultUnlocked` if you want special skins to be granted only by staff.

## Commands

- `/armasvip` — administrative assignment UI (ACE protected)
- `/misarmasvip` — personal VIP arsenal + Weapon Studio
- `/armasvipgestionar` — persistent grant management
- `/armasvipskins` — admin skin unlock manager (ACE protected)
- `/vipinspect` — inspect the equipped VIP weapon (`I` by default)

See **[WEAPON_STUDIO.md](WEAPON_STUDIO.md)** for skin configuration, custom assets and rendering limitations.

## Updating

1. Back up your server and database.
2. Download the new versioned Release ZIP.
3. Replace the resource files while preserving intentional configuration changes.
4. Review the changelog.
5. Restart the resource/server.

## Development

Frontend development instructions are intentionally kept out of the server installation flow. Contributors modifying the React/TypeScript NUI should use **[DEVELOPMENT.md](DEVELOPMENT.md)**.
