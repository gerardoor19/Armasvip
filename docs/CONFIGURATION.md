# Configuration

Configuration lives in `config/config.lua`. Language is selected through the ox_lib locale convar.

## Language

```cfg
setr ox:locale es
```

or:

```cfg
setr ox:locale en
```

Both `locales/es.json` and `locales/en.json` cover Lua menus, notifications, NUI strings, categories and VIP item presentation.

## Identity

`Config.Identity.Provider = 'auto'` resolves identity in this order:

1. Qbox (`qbx_core`)
2. QBCore (`qb-core`)
3. ESX (`es_extended`)
4. Rockstar license fallback

You can force `qbox`, `qbcore`, `esx` or `license` when required.

## Permissions

The default administrative ACE is:

```lua
Config.Ace = 'armasvip.admin'
```

Administrative authorization is checked server-side. NUI visibility is never treated as permission.

## Persistent grants

Key options under `Config.Grants`:

- `DurationOptions` — durations exposed to administrators using localized label keys.
- `MaxDurationDays` — maximum accepted finite duration.
- `ProtectTransfers` — blocks normal transfer of VIP instances through `ox_inventory` hooks.
- `InfiniteDurability` and `Durability` — instance-level durability behavior.
- `DefaultTintUnlocked` — base cosmetic entitlement.
- `ExpiryCheckSeconds` — server-side expiration interval.
- `ItemPresentation` — instance-only label suffix and localized metadata values.

Keep credentials and private identifiers outside the repository.
