# Configuration

Configuration lives in `config/config.lua`.

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

Administrative authorization is checked server-side. Do not treat NUI visibility as permission.

## Persistent grants

Grant duration, transfer protection, VIP item presentation, durability behavior and tint defaults are configurable under `Config.Grants`.

Key options include:

- `DurationOptions` — durations exposed to administrators.
- `MaxDurationDays` — maximum accepted finite duration.
- `ProtectTransfers` — blocks normal transfer of VIP instances through `ox_inventory` hooks.
- `InfiniteDurability` and `Durability` — instance-level durability behavior.
- `DefaultTintUnlocked` — base cosmetic entitlement.
- `ExpiryCheckSeconds` — server-side expiration interval.

Keep sensitive credentials outside this file and outside the repository.
