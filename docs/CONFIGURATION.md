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

Both locales cover Lua menus, notifications, the React NUI, Weapon Studio and VIP item presentation.

## Identity

`Config.Identity.Provider = 'auto'` resolves identity in this order:

1. Qbox (`qbx_core`)
2. QBCore (`qb-core`)
3. ESX (`es_extended`)
4. Rockstar license fallback

You can force `qbox`, `qbcore`, `esx` or `license` when required.

## Permissions and commands

The default administrative ACE is:

```lua
Config.Ace = 'armasvip.admin'
```

Commands are configurable through `Config.Command`, `Config.PlayerCommand`, `Config.ManageCommand` and `Config.SkinManageCommand`. Administrative authorization is always checked server-side.

## Weapon Studio

`Config.Skins` controls the runtime skin system:

```lua
Config.Skins = {
    Enabled = true,
    TextureSize = 512,
    DuiTimeoutMs = 5000,
    AllowExternalUrls = false,
    DefaultUnlocked = { 'default', 'carbon', 'gold', 'galaxy' },
    Inspect = {
        Enabled = true,
        Command = 'vipinspect',
        Key = 'I',
        Dict = 'shared@fidgets',
        Clip = 'fidget_med_loop',
        Duration = 2600,
        Flag = 49,
    },
}
```

- `Enabled` toggles runtime texture application.
- `TextureSize` controls the DUI texture resolution (clamped between 128 and 1024).
- `DuiTimeoutMs` limits how long the client waits for the local renderer.
- `AllowExternalUrls` is disabled by default. Keep it disabled unless you explicitly trust external skin hosts.
- `DefaultUnlocked` lists skins available automatically for every compatible VIP grant.
- `Inspect` controls the inspect command/key and GTA animation.

The skin catalog and weapon texture mappings live in `shared/skins.lua`. See [Weapon Studio](WEAPON_STUDIO.md).

## Persistent grants

Key options under `Config.Grants`:

- `DurationOptions` — durations exposed to administrators using localized label keys.
- `MaxDurationDays` — maximum accepted finite duration.
- `ProtectTransfers` — blocks normal transfer of VIP instances through `ox_inventory` hooks.
- `InfiniteDurability` and `Durability` — instance-level durability behavior.
- `DefaultTintUnlocked` — base tint entitlement.
- `ExpiryCheckSeconds` — server-side expiration interval.
- `ItemPresentation` — instance-only label suffix and localized metadata values.

Keep credentials, private identifiers and untrusted remote asset URLs outside the repository.
