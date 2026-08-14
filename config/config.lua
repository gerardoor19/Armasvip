Config = {}

-- Administrative commands and permission.
Config.Command = 'armasvip'
Config.Ace = 'armasvip.admin'
Config.PlayerCommand = 'misarmasvip'
Config.ManageCommand = 'armasvipgestionar'
Config.SkinManageCommand = 'armasvipskins'

-- Legacy callback ammunition. Kept for backwards compatibility.
Config.ChamberAmmo = 250
Config.ReserveAmmo = 250

-- Persistent VIP weapon ammunition.
-- ReserveAmmoOnEquip = 0 prevents the arsenal from being used to farm ammo boxes.
Config.VipChamberAmmo = 250
Config.VipReserveAmmoOnEquip = 0

Config.TintIndexes = { 0, 1, 2, 3, 4, 5, 6, 7 }

-- Runtime Weapon Studio skins.
-- The bundled skins use a local HTML/DUI renderer, so server owners do not need
-- Blender, custom weapon models or external image hosting.
Config.Skins = {
    Enabled = true,
    TextureSize = 512,
    DuiTimeoutMs = 5000,
    AllowExternalUrls = false,

    -- These skins are automatically available on every compatible VIP grant.
    -- Leave only 'default' here if every special skin should be granted manually.
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

-- Persistent owner identity.
-- auto: qbx_core -> qb-core -> es_extended -> Rockstar license.
-- Can be forced to: 'qbox', 'qbcore', 'esx' or 'license'.
Config.Identity = {
    Provider = 'auto',
}

Config.Grants = {
    -- Durations available to staff. 0 = permanent.
    DurationOptions = {
        { days = 0, labelKey = 'duration_permanent' },
        { days = 30, labelKey = 'duration_30_days' },
        { days = 90, labelKey = 'duration_90_days' },
    },

    MaxDurationDays = 3650,
    ProtectTransfers = true,

    -- Presentation applies only to instances created by ArmasVIP.
    ItemPresentation = {
        LabelSuffix = ' [VIP]',
        Type = locale('vip_item_type'),
        Description = locale('vip_item_description'),
    },

    InfiniteDurability = true,
    Durability = 100,
    DefaultTintUnlocked = 0,
    ExpiryCheckSeconds = 60,
}
