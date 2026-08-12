# Installation

## Recommended installation: GitHub Release

For a normal FiveM server installation, download the versioned **ArmasVIP release asset** from GitHub Releases.

Use:

```text
ArmasVIP-v2.3.1.zip
```

The official release asset already includes the compiled NUI. **Server owners do not need Node.js, npm or any frontend build step.**

Do not confuse the official release asset with GitHub's automatically generated `Source code (zip)` or `Source code (tar.gz)` archives. Those source archives are intended for developers and contain repository-only files.

## Requirements

- `oxmysql`
- `ox_lib`
- `ox_inventory`
- Optional identity integration: Qbox, QBCore or ESX

## Install the resource

1. Download `ArmasVIP-v2.3.1.zip` from the Releases page.
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

Choose one locale in `server.cfg`.

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

Administrative actions use `armasvip.admin`:

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

ArmasVIP contains bootstrap/migration logic for its required tables. If you prefer manual installation, `sql/install.sql` is included in the release package.

## Commands

- `/armasvip` — administrative assignment UI (ACE protected)
- `/misarmasvip` — personal VIP arsenal
- `/armasvipgestionar` — persistent grant management

## Updating

When a new ArmasVIP version is released:

1. Back up your server and database.
2. Download the new versioned Release ZIP.
3. Replace the resource files while preserving any intentional configuration changes.
4. Review the changelog for migrations or behavior changes.
5. Restart the resource/server.

## Development

Frontend development instructions are intentionally kept out of the server installation flow. Contributors who modify the React/TypeScript NUI should use **[DEVELOPMENT.md](DEVELOPMENT.md)**.
