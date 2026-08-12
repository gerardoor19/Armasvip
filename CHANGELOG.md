# Changelog

All notable changes to ArmasVIP are documented here.

## [2.3.1] - 2026-08-12

### Added
- Full Spanish and English localization for Lua menus, notifications and the React NUI.
- Localized weapon categories, grant management, recovery messages and VIP item presentation.
- Automated GitHub Release packaging from version tags.

### Changed
- The official release ZIP contains runtime files only: no Markdown documentation, TypeScript source, Node metadata, audit notes or local build artifacts.
- Normal server installation uses the versioned GitHub Release asset and requires no Node.js, npm or NUI build step.
- Server owners select the language through `setr ox:locale es` or `setr ox:locale en`.
- Runtime package creation is allow-list based to prevent development files from leaking into releases.
- README and installation documentation now clearly separate server installation from contributor/frontend development.

## [2.3.0] - 2026-08-11

### Changed
- Published the complete runtime and NUI source code on GitHub.
- Removed the Cfx Asset Escrow/Tebex distribution requirement.
- Standardized the administrative ACE permission as `armasvip.admin`.
- Cleaned internal audit notes and local TypeScript build artifacts from the public tree.
- Added an open-source license, contribution guidance and a repository `.gitignore`.
- Reworked installation and development documentation for direct GitHub distribution.

### Security
- Server-side authorization remains authoritative for administrative and ownership-sensitive operations.

## [2.2.0] - 2026-08-10
- Documentation and presentation release from the previous protected-distribution model.
