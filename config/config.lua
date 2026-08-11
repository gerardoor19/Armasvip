Config = {}

-- Panel administrativo.
Config.Command = 'armasvip'
Config.Ace = 'armasvip.admin'

-- Menú personal y gestión de asignaciones.
Config.PlayerCommand = 'misarmasvip'
Config.ManageCommand = 'armasvipgestionar'

-- Munición del callback legacy armasvip:giveWeapon (se conserva por compatibilidad).
Config.ChamberAmmo = 250
Config.ReserveAmmo = 250

-- Munición del sistema VIP persistente.
-- Reserve=0 evita que /misarmasvip pueda usarse para farmear cajas de munición.
Config.VipChamberAmmo = 250
Config.VipReserveAmmoOnEquip = 0

-- Índices de tinte disponibles para todas las armas.
Config.TintIndexes = { 0, 1, 2, 3, 4, 5, 6, 7 }

-- Identidad persistente del propietario.
-- auto: qbx_core -> qb-core -> es_extended -> Rockstar license.
-- Se puede forzar: 'qbox', 'qbcore', 'esx' o 'license'.
Config.Identity = {
    Provider = 'auto',
}

Config.Grants = {
    -- Duraciones que puede vender/asignar el staff. 0 = permanente.
    DurationOptions = {
        { days = 0, label = 'Permanente' },
        { days = 30, label = '30 días' },
        { days = 90, label = '90 días' },
    },

    MaxDurationDays = 3650,

    -- Bloquea transferencias normales de ox_inventory hacia jugadores,
    -- drops, stashes, trunks, gloveboxes u otros inventarios.
    ProtectTransfers = true,

    -- Presentación exclusiva de las instancias VIP dentro de ox_inventory.
    -- Solo afecta a items creados por este sistema; un WEAPON_* normal no cambia.
    ItemPresentation = {
        LabelSuffix = ' [VIP]',
        Type = 'VIP PERSONAL',
        Description = 'Arma VIP personal · No transferible · Sin desgaste',
    },

    -- Las armas VIP no se degradan. Se mantiene la durabilidad del item en 100
    -- sin modificar la definición base WEAPON_* de ox_inventory.
    InfiniteDurability = true,
    Durability = 100,

    -- Camos/tintes: el 0 (acabado por defecto) siempre está desbloqueado.
    DefaultTintUnlocked = 0,

    -- Revisión periódica de expiraciones.
    ExpiryCheckSeconds = 60,
}
