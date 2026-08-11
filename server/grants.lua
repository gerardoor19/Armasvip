ArmasVipGrants = ArmasVipGrants or {}

local weaponsByName = {}
for _, weapon in ipairs(ArmasVipData.weapons) do
    weaponsByName[weapon.name:upper()] = weapon
end

local byId = {}
local byOwner = {}
local tintsByGrant = {}
local ready = false
local bootstrapError = nil
local grantLocks = {}
local repairCooldowns = {}

local function acquireGrantLock(id)
    id = tonumber(id)
    if not id then return nil end

    local deadline = GetGameTimer() + 5000
    while grantLocks[id] and GetGameTimer() < deadline do Wait(0) end
    if grantLocks[id] then return nil end

    grantLocks[id] = true
    return id
end

local function releaseGrantLock(id)
    if id then grantLocks[id] = nil end
end

local function decodeComponents(value)
    if type(value) == 'table' then return value end
    if type(value) ~= 'string' or value == '' then return {} end
    local ok, decoded = pcall(json.decode, value)
    return ok and type(decoded) == 'table' and decoded or {}
end

local function normalize(row)
    row.id = tonumber(row.id)
    row.tint = tonumber(row.tint) or 0
    row.initial_delivered = tonumber(row.initial_delivered) or 0
    row.components = decodeComponents(row.components)
    row.weapon = tostring(row.weapon):upper()
    return row
end

local function clearCache()
    byId = {}
    byOwner = {}
    tintsByGrant = {}
end

local function cacheGrant(grant)
    grant = normalize(grant)
    byId[grant.id] = grant
    byOwner[grant.owner_key] = byOwner[grant.owner_key] or {}
    byOwner[grant.owner_key][grant.id] = grant
    return grant
end

local function uncacheGrant(id)
    local grant = byId[tonumber(id)]
    if not grant then return end

    byId[grant.id] = nil
    local owner = byOwner[grant.owner_key]
    if owner then
        owner[grant.id] = nil
        if not next(owner) then byOwner[grant.owner_key] = nil end
    end
end

local function createSchema()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `armasvip_grants` (
            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            `owner_key` VARCHAR(160) NOT NULL,
            `owner_name` VARCHAR(100) NOT NULL,
            `weapon` VARCHAR(80) NOT NULL,
            `components` LONGTEXT NOT NULL,
            `tint` TINYINT UNSIGNED NOT NULL DEFAULT 0,
            `assigned_by` VARCHAR(160) NOT NULL,
            `assigned_by_name` VARCHAR(100) NOT NULL,
            `assigned_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `expires_at` TIMESTAMP NULL DEFAULT NULL,
            `status` VARCHAR(16) NOT NULL DEFAULT 'active',
            `initial_delivered` TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`),
            KEY `idx_armasvip_owner_status` (`owner_key`, `status`),
            KEY `idx_armasvip_expiry` (`status`, `expires_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Migración segura para instalaciones 2.0.x ya existentes: sus grants ya
    -- tuvieron una primera entrega, por lo que no deben regenerar accesorios.
    -- Evitamos MySQL.single para mantener compatibilidad con instalaciones antiguas
    -- de oxmysql que sí soportan query.await pero no todos los helpers modernos.
    local columns = MySQL.query.await("SHOW COLUMNS FROM `armasvip_grants` LIKE 'initial_delivered'") or {}
    if #columns == 0 then
        MySQL.query.await([[
            ALTER TABLE armasvip_grants
            ADD COLUMN initial_delivered TINYINT(1) NOT NULL DEFAULT 1 AFTER status
        ]])
    end

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `armasvip_cosmetics` (
            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
            `grant_id` BIGINT UNSIGNED NOT NULL,
            `cosmetic_type` VARCHAR(24) NOT NULL,
            `cosmetic_value` VARCHAR(80) NOT NULL,
            `unlocked_by` VARCHAR(160) NOT NULL DEFAULT 'system',
            `unlocked_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `uq_armasvip_cosmetic` (`grant_id`, `cosmetic_type`, `cosmetic_value`),
            KEY `idx_armasvip_cosmetic_grant` (`grant_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    -- Todo grant, incluso uno antiguo, conserva el acabado base. También
    -- migramos el tinte activo histórico como desbloqueado para no quitarle
    -- nada que el jugador ya tenía comprado/asignado.
    MySQL.query.await([[
        INSERT IGNORE INTO armasvip_cosmetics (grant_id, cosmetic_type, cosmetic_value, unlocked_by)
        SELECT id, 'tint', '0', 'migration' FROM armasvip_grants
    ]])
    MySQL.query.await([[
        INSERT IGNORE INTO armasvip_cosmetics (grant_id, cosmetic_type, cosmetic_value, unlocked_by)
        SELECT id, 'tint', CAST(tint AS CHAR), 'migration'
        FROM armasvip_grants WHERE tint > 0
    ]])
end

local function reloadCache()
    clearCache()

    local rows = MySQL.query.await([[
        SELECT id, owner_key, owner_name, weapon, components, tint, assigned_by,
               assigned_by_name, assigned_at, expires_at, status, initial_delivered
        FROM armasvip_grants
        WHERE status = 'active' AND (expires_at IS NULL OR expires_at > NOW())
    ]]) or {}

    for _, row in ipairs(rows) do cacheGrant(row) end

    local cosmeticRows = MySQL.query.await([[
        SELECT c.grant_id, c.cosmetic_value
        FROM armasvip_cosmetics c
        INNER JOIN armasvip_grants g ON g.id = c.grant_id
        WHERE c.cosmetic_type = 'tint'
          AND g.status = 'active'
          AND (g.expires_at IS NULL OR g.expires_at > NOW())
    ]]) or {}
    for _, row in ipairs(cosmeticRows) do
        local grantId = tonumber(row.grant_id)
        local tint = tonumber(row.cosmetic_value)
        if grantId and tint then
            tintsByGrant[grantId] = tintsByGrant[grantId] or {}
            tintsByGrant[grantId][tint] = true
        end
    end

    ready = true
    print(('[armasvip] Loaded %d active VIP weapon grants.'):format(#rows))
end

local function waitReady()
    local deadline = GetGameTimer() + 10000
    while not ready and GetGameTimer() < deadline do Wait(0) end
    return ready
end

local function resolveTint(requested)
    local value = tonumber(requested) or 0
    for _, allowed in ipairs(Config.TintIndexes) do
        if value == allowed then return value end
    end
    return 0
end

local function resolveComponents(weapon, requested)
    if type(requested) ~= 'table' then return {} end

    local allowed = {}
    for _, name in ipairs(weapon.components or {}) do allowed[name] = true end

    local output, seen = {}, {}
    for _, name in ipairs(requested) do
        if type(name) == 'string' and allowed[name] and not seen[name] then
            seen[name] = true
            output[#output + 1] = name
        end
    end

    return output
end

local function isVipWeapon(metadata)
    return type(metadata) == 'table'
        and metadata.armasvip == true
        and tonumber(metadata.vipGrantId) ~= nil
        and type(metadata.vipOwner) == 'string'
        and metadata.vipOwner ~= ''
end

local function vipDurability()
    local configured = tonumber(Config.Grants and Config.Grants.Durability) or 100
    return math.max(1, math.min(100, configured))
end

local function applyVipPresentation(metadata, weapon)
    metadata = type(metadata) == 'table' and metadata or {}

    local presentation = Config.Grants and Config.Grants.ItemPresentation or {}
    local suffix = tostring(presentation.LabelSuffix or ' [VIP]')

    -- `label`, `description` y `type` son metadata visual especial de ox_inventory.
    -- Se aplican solo a esta instancia VIP; el item base WEAPON_* no se modifica.
    metadata.label = ('%s%s'):format(weapon.label or weapon.name, suffix)
    metadata.description = tostring(presentation.Description or 'Arma VIP personal · No transferible · Sin desgaste')
    metadata.type = tostring(presentation.Type or 'VIP PERSONAL')

    return metadata
end

local function applyGrantMetadata(metadata, grant, ownerKey, weapon, installInitialComponents)
    metadata = type(metadata) == 'table' and metadata or {}

    -- Campos autoritativos del grant. No tocamos serial, registered, specialAmmo
    -- u otra metadata que ox_inventory u otros recursos hayan añadido al item.
    -- Los accesorios NO son propiedad permanente. Solo se regeneran en la
    -- primera entrega de un grant nuevo. Después preservamos exactamente los
    -- que tenga la instancia física; si se perdieron/robaron, no reaparecen.
    if installInitialComponents then
        metadata.components = resolveComponents(weapon, decodeComponents(grant.components))
    else
        metadata.components = resolveComponents(weapon, metadata.components or {})
    end
    metadata.armasvip = true
    metadata.vipGrantId = tonumber(grant.id)
    metadata.vipOwner = ownerKey
    metadata.vipNonTransferable = true

    if grant.tint and tonumber(grant.tint) and tonumber(grant.tint) > 0 then
        metadata.tint = tonumber(grant.tint)
    else
        metadata.tint = nil
    end

    if Config.Grants.InfiniteDurability ~= false then
        metadata.durability = vipDurability()
    end

    return applyVipPresentation(metadata, weapon)
end

local function normalizeVipSlot(source, slot, grant, ownerKey, weapon)
    if type(slot) ~= 'table' or not slot.slot then return false end

    local refreshed = {}
    for key, value in pairs(type(slot.metadata) == 'table' and slot.metadata or {}) do
        refreshed[key] = value
    end

    applyGrantMetadata(refreshed, grant, ownerKey, weapon, false)
    exports.ox_inventory:SetMetadata(source, slot.slot, refreshed)

    if Config.Grants.InfiniteDurability ~= false then
        -- SetDurability es la API oficial de ox_inventory para reparar el slot y
        -- fuerza la sincronización correcta sin alterar el item base WEAPON_*.
        exports.ox_inventory:SetDurability(source, slot.slot, vipDurability())
    end

    return true
end

ArmasVipGrants.IsVipWeapon = isVipWeapon

local function publicGrant(grant)
    local weapon = weaponsByName[grant.weapon]
    if not weapon then return nil end

    return {
        id = grant.id,
        weapon = grant.weapon,
        label = weapon.label,
        category = weapon.category,
        components = grant.components,
        tint = grant.tint,
        assignedAt = grant.assigned_at,
        expiresAt = grant.expires_at,
        ownerName = grant.owner_name,
        ownerKey = grant.owner_key,
        assignedByName = grant.assigned_by_name,
        status = grant.status,
        initialDelivered = grant.initial_delivered == 1,
        unlockedTints = (function()
            local values = {}
            for tint in pairs(tintsByGrant[grant.id] or {}) do values[#values + 1] = tint end
            table.sort(values)
            return values
        end)(),
    }
end

local function removePhysicalItem(grant)
    local playerSource = ArmasVipIdentity.FindOnlineByKey(grant.owner_key)
    if not playerSource then return 0 end

    local slots = exports.ox_inventory:GetSlotsWithItem(
        playerSource,
        grant.weapon,
        { vipGrantId = grant.id },
        false
    ) or {}

    local removed = 0
    for _, slot in ipairs(slots) do
        local success = exports.ox_inventory:RemoveItem(
            playerSource,
            grant.weapon,
            slot.count or 1,
            slot.metadata,
            slot.slot,
            false,
            true
        )
        if success then removed = removed + 1 end
    end

    return removed
end

function ArmasVipGrants.GetWeapon(name)
    return type(name) == 'string' and weaponsByName[name:upper()] or nil
end

function ArmasVipGrants.ResolveComponents(weapon, requested)
    return resolveComponents(weapon, requested)
end

function ArmasVipGrants.ResolveTint(requested)
    return resolveTint(requested)
end

function ArmasVipGrants.GetOwner(ownerKey)
    if not waitReady() then return {} end

    local grants = {}
    for _, grant in pairs(byOwner[ownerKey] or {}) do
        local public = publicGrant(grant)
        if public then grants[#grants + 1] = public end
    end

    table.sort(grants, function(a, b) return a.id > b.id end)
    return grants
end

function ArmasVipGrants.GetAll()
    if not waitReady() then return {} end

    local grants = {}
    for _, grant in pairs(byId) do
        local public = publicGrant(grant)
        if public then grants[#grants + 1] = public end
    end

    table.sort(grants, function(a, b)
        if a.ownerName == b.ownerName then return a.id > b.id end
        return tostring(a.ownerName):lower() < tostring(b.ownerName):lower()
    end)

    return grants
end

function ArmasVipGrants.Get(id)
    if not waitReady() then return nil end
    return byId[tonumber(id)]
end

function ArmasVipGrants.Create(adminSource, targetSource, payload)
    if not waitReady() then return false, 'database_not_ready' end

    local admin = ArmasVipIdentity.Get(adminSource)
    local owner = ArmasVipIdentity.Get(targetSource)
    if not admin or not owner then return false, 'invalid_identity' end

    if type(payload) ~= 'table' or type(payload.weapon) ~= 'string' then
        return false, 'invalid_payload'
    end

    local weapon = ArmasVipGrants.GetWeapon(payload.weapon)
    if not weapon then return false, 'invalid_weapon' end

    local components = resolveComponents(weapon, payload.components)
    local tint = resolveTint(payload.tint)

    local days = math.floor(tonumber(payload.durationDays) or 0)
    if days < 0 then days = 0 end
    days = math.min(days, tonumber(Config.Grants.MaxDurationDays) or 3650)

    local expiresEpoch = days > 0 and (os.time() + days * 86400) or nil
    local id

    if expiresEpoch then
        id = MySQL.insert.await([[
            INSERT INTO armasvip_grants
                (owner_key, owner_name, weapon, components, tint, assigned_by, assigned_by_name, expires_at, status, initial_delivered)
            VALUES (?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?), 'active', 0)
        ]], {
            owner.key,
            owner.name,
            weapon.name,
            json.encode(components),
            tint,
            admin.key,
            admin.name,
            expiresEpoch,
        })
    else
        id = MySQL.insert.await([[
            INSERT INTO armasvip_grants
                (owner_key, owner_name, weapon, components, tint, assigned_by, assigned_by_name, expires_at, status, initial_delivered)
            VALUES (?, ?, ?, ?, ?, ?, ?, NULL, 'active', 0)
        ]], {
            owner.key,
            owner.name,
            weapon.name,
            json.encode(components),
            tint,
            admin.key,
            admin.name,
        })
    end

    if not id then return false, 'database_error' end

    local rows = MySQL.query.await([[
        SELECT id, owner_key, owner_name, weapon, components, tint, assigned_by,
               assigned_by_name, assigned_at, expires_at, status, initial_delivered
        FROM armasvip_grants
        WHERE id = ?
        LIMIT 1
    ]], { id })

    local grant = rows and rows[1] and cacheGrant(rows[1])
    if not grant then return false, 'database_error' end

    local defaultTint = resolveTint(Config.Grants.DefaultTintUnlocked or 0)
    MySQL.insert.await([[
        INSERT IGNORE INTO armasvip_cosmetics (grant_id, cosmetic_type, cosmetic_value, unlocked_by)
        VALUES (?, 'tint', ?, ?)
    ]], { grant.id, tostring(defaultTint), admin.key })
    tintsByGrant[grant.id] = tintsByGrant[grant.id] or {}
    tintsByGrant[grant.id][defaultTint] = true

    if tint ~= defaultTint then
        MySQL.insert.await([[
            INSERT IGNORE INTO armasvip_cosmetics (grant_id, cosmetic_type, cosmetic_value, unlocked_by)
            VALUES (?, 'tint', ?, ?)
        ]], { grant.id, tostring(tint), admin.key })
        tintsByGrant[grant.id][tint] = true
    end

    return true, publicGrant(grant)
end

function ArmasVipGrants.Revoke(_, id)
    if not waitReady() then return false, 'database_not_ready' end

    local lockId = acquireGrantLock(id)
    if not lockId then return false, 'grant_busy' end

    local function finish(ok, result)
        releaseGrantLock(lockId)
        return ok, result
    end

    local grant = byId[tonumber(id)]
    if not grant then return finish(false, 'grant_not_found') end

    local changed = MySQL.update.await(
        "UPDATE armasvip_grants SET status = 'revoked' WHERE id = ? AND status = 'active'",
        { grant.id }
    )

    if not changed or changed < 1 then return finish(false, 'grant_not_found') end

    removePhysicalItem(grant)
    uncacheGrant(grant.id)
    return finish(true)
end

function ArmasVipGrants.Equip(source, id)
    if not waitReady() then return false, 'database_not_ready' end

    local lockId = acquireGrantLock(id)
    if not lockId then return false, 'grant_busy' end

    local function finish(ok, result)
        releaseGrantLock(lockId)
        return ok, result
    end

    local owner = ArmasVipIdentity.Get(source)
    if not owner then return finish(false, 'invalid_identity') end

    -- Revalidación autoritativa en SQL. El cliente solo manda grantId.
    local rows = MySQL.query.await([[
        SELECT id, owner_key, owner_name, weapon, components, tint, assigned_by,
               assigned_by_name, assigned_at, expires_at, status, initial_delivered
        FROM armasvip_grants
        WHERE id = ? AND owner_key = ? AND status = 'active'
          AND (expires_at IS NULL OR expires_at > NOW())
        LIMIT 1
    ]], { tonumber(id), owner.key })

    local grant = rows and rows[1] and normalize(rows[1])
    if not grant then return finish(false, 'grant_not_found') end

    local weapon = ArmasVipGrants.GetWeapon(grant.weapon)
    if not weapon then return finish(false, 'invalid_weapon') end

    -- Anti-duplicado por grant, no solo por nombre del arma.
    local existing = exports.ox_inventory:GetSlotIdWithItem(
        source,
        weapon.name,
        { vipGrantId = grant.id },
        false
    )
    if existing then return finish(false, 'already_equipped') end

    local firstDelivery = grant.initial_delivered ~= 1
    local metadata = applyGrantMetadata({}, grant, owner.key, weapon, firstDelivery)

    if not weapon.throwable then
        metadata.ammo = math.max(0, math.floor(tonumber(Config.VipChamberAmmo) or 0))
    end

    if not exports.ox_inventory:CanCarryItem(source, weapon.name, 1, metadata) then
        return finish(false, 'inventory_full')
    end

    local success, response = exports.ox_inventory:AddItem(source, weapon.name, 1, metadata)
    if not success then return finish(false, response or 'inventory_error') end

    -- AddItem puede pasar por hooks createItem de otros recursos. Para una concesión VIP
    -- componentes/tinte/propietario/durabilidad son autoritativos, pero serial, registered,
    -- specialAmmo y cualquier otra metadata generada por ox_inventory se preservan.
    if type(response) == 'table' and response.slot then
        local finalMetadata = {}
        if type(response.metadata) == 'table' then
            for key, value in pairs(response.metadata) do finalMetadata[key] = value end
        end

        applyGrantMetadata(finalMetadata, grant, owner.key, weapon, firstDelivery)

        if not weapon.throwable then
            finalMetadata.ammo = math.max(0, math.floor(tonumber(Config.VipChamberAmmo) or 0))
        end

        exports.ox_inventory:SetMetadata(source, response.slot, finalMetadata)
        if Config.Grants.InfiniteDurability ~= false then
            exports.ox_inventory:SetDurability(source, response.slot, vipDurability())
        end
    end

    if firstDelivery then
        MySQL.update.await('UPDATE armasvip_grants SET initial_delivered = 1 WHERE id = ?', { grant.id })
        grant.initial_delivered = 1
        if byId[grant.id] then byId[grant.id].initial_delivered = 1 end
    end

    local reserve = math.max(0, math.floor(tonumber(Config.VipReserveAmmoOnEquip) or 0))
    if reserve > 0 and weapon.ammoname and not weapon.throwable then
        exports.ox_inventory:AddItem(source, weapon.ammoname, reserve)
    end

    return finish(true, publicGrant(grant))
end

function ArmasVipGrants.GetOwnerState(source)
    if not waitReady() then return nil, 'database_not_ready' end

    local owner = ArmasVipIdentity.Get(source)
    if not owner then return nil, 'invalid_identity' end

    local grants = ArmasVipGrants.GetOwner(owner.key)
    for _, public in ipairs(grants) do
        local slot = exports.ox_inventory:GetSlotWithItem(
            source,
            public.weapon,
            { vipGrantId = public.id },
            false
        )
        public.inInventory = slot ~= nil
        public.slot = slot and slot.slot or nil
        public.installedComponents = slot and resolveComponents(weaponsByName[public.weapon], slot.metadata and slot.metadata.components or {}) or {}
        public.durability = slot and tonumber(slot.metadata and slot.metadata.durability) or nil
    end

    return { grants = grants, ownerName = owner.name }
end

local function syncGrantTintToPhysical(grant, tint)
    local playerSource = ArmasVipIdentity.FindOnlineByKey(grant.owner_key)
    if not playerSource then return end

    local slot = exports.ox_inventory:GetSlotWithItem(
        playerSource,
        grant.weapon,
        { vipGrantId = grant.id },
        false
    )
    if not slot then return end

    local metadata = {}
    for key, value in pairs(type(slot.metadata) == 'table' and slot.metadata or {}) do metadata[key] = value end
    if tint > 0 then metadata.tint = tint else metadata.tint = nil end
    exports.ox_inventory:SetMetadata(playerSource, slot.slot, metadata)
    TriggerClientEvent('armasvip:client:applyVipTint', playerSource, grant.id, grant.weapon, tint)
end

function ArmasVipGrants.SetActiveTint(source, id, requestedTint)
    if not waitReady() then return false, 'database_not_ready' end

    local owner = ArmasVipIdentity.Get(source)
    if not owner then return false, 'invalid_identity' end
    local grant = byId[tonumber(id)]
    if not grant or grant.owner_key ~= owner.key then return false, 'grant_not_found' end

    local tint = resolveTint(requestedTint)
    if not (tintsByGrant[grant.id] and tintsByGrant[grant.id][tint]) then
        return false, 'tint_locked'
    end

    MySQL.update.await('UPDATE armasvip_grants SET tint = ? WHERE id = ?', { tint, grant.id })
    grant.tint = tint
    syncGrantTintToPhysical(grant, tint)
    return true, publicGrant(grant)
end

function ArmasVipGrants.SetTintUnlocked(adminSource, id, requestedTint, unlocked)
    if not waitReady() then return false, 'database_not_ready' end
    local admin = ArmasVipIdentity.Get(adminSource)
    if not admin then return false, 'invalid_identity' end

    local grant = byId[tonumber(id)]
    if not grant then return false, 'grant_not_found' end
    local tint = resolveTint(requestedTint)
    local defaultTint = resolveTint(Config.Grants.DefaultTintUnlocked or 0)

    tintsByGrant[grant.id] = tintsByGrant[grant.id] or {}
    if unlocked then
        MySQL.insert.await([[
            INSERT IGNORE INTO armasvip_cosmetics (grant_id, cosmetic_type, cosmetic_value, unlocked_by)
            VALUES (?, 'tint', ?, ?)
        ]], { grant.id, tostring(tint), admin.key })
        tintsByGrant[grant.id][tint] = true
    else
        if tint == defaultTint then return false, 'default_tint' end
        MySQL.query.await([[
            DELETE FROM armasvip_cosmetics
            WHERE grant_id = ? AND cosmetic_type = 'tint' AND cosmetic_value = ?
        ]], { grant.id, tostring(tint) })
        tintsByGrant[grant.id][tint] = nil
        if grant.tint == tint then
            grant.tint = defaultTint
            MySQL.update.await('UPDATE armasvip_grants SET tint = ? WHERE id = ?', { defaultTint, grant.id })
            syncGrantTintToPhysical(grant, defaultTint)
        end
    end

    return true, publicGrant(grant)
end

function ArmasVipGrants.RepairVipSlot(source, slotId, expectedGrantId)
    if Config.Grants.InfiniteDurability == false then return false, 'disabled' end
    if not waitReady() then return false, 'database_not_ready' end

    slotId = tonumber(slotId)
    expectedGrantId = tonumber(expectedGrantId)
    if not slotId or not expectedGrantId then return false, 'invalid_request' end

    -- Defensa adicional ante spam del evento de reparación. Una sincronización normal
    -- de ox_inventory no necesita reparar el mismo grant varias veces en 250 ms.
    local cooldownKey = ('%s:%s'):format(source, expectedGrantId)
    local now = GetGameTimer()
    if repairCooldowns[cooldownKey] and now - repairCooldowns[cooldownKey] < 250 then
        return false, 'rate_limited'
    end
    repairCooldowns[cooldownKey] = now

    local owner = ArmasVipIdentity.Get(source)
    if not owner then return false, 'invalid_identity' end

    local items = exports.ox_inventory:GetInventoryItems(source) or {}
    local slot = items[slotId]
    if type(slot) ~= 'table' or not isVipWeapon(slot.metadata) then
        return false, 'not_vip'
    end

    local grantId = tonumber(slot.metadata.vipGrantId)
    if grantId ~= expectedGrantId then return false, 'grant_mismatch' end

    local grant = byId[grantId]
    if not grant
        or grant.owner_key ~= owner.key
        or tostring(grant.weapon):upper() ~= tostring(slot.name):upper()
        or slot.metadata.vipOwner ~= owner.key then
        return false, 'grant_not_found'
    end

    exports.ox_inventory:SetDurability(source, slotId, vipDurability())
    return true
end

function ArmasVipGrants.CleanupInventory(source)
    if not waitReady() then return 0 end

    local owner = ArmasVipIdentity.Get(source)
    if not owner then return 0 end

    local items = exports.ox_inventory:GetInventoryItems(source) or {}
    local seen, removed = {}, 0

    for _, slot in pairs(items) do
        local metadata = type(slot) == 'table' and slot.metadata or nil
        local grantId = type(metadata) == 'table' and tonumber(metadata.vipGrantId) or nil

        if metadata and metadata.armasvip == true and grantId then
            local grant = byId[grantId]
            local valid = grant
                and grant.owner_key == owner.key
                and tostring(grant.weapon):upper() == tostring(slot.name):upper()
                and not seen[grantId]

            if valid then
                seen[grantId] = true

                local weapon = ArmasVipGrants.GetWeapon(grant.weapon)
                if weapon then
                    normalizeVipSlot(source, slot, grant, owner.key, weapon)
                end
            else
                local success = exports.ox_inventory:RemoveItem(
                    source,
                    slot.name,
                    slot.count or 1,
                    slot.metadata,
                    slot.slot,
                    false,
                    true
                )
                if success then removed = removed + 1 end
            end
        end
    end

    return removed
end

AddEventHandler('playerDropped', function()
    local prefix = ('%s:'):format(source)
    for key in pairs(repairCooldowns) do
        if key:sub(1, #prefix) == prefix then repairCooldowns[key] = nil end
    end
end)

function ArmasVipGrants.Refresh()
    reloadCache()
end

CreateThread(function()
    local deadline = GetGameTimer() + 30000
    while GetResourceState('oxmysql') ~= 'started' and GetGameTimer() < deadline do
        Wait(250)
    end

    if GetResourceState('oxmysql') ~= 'started' then
        bootstrapError = 'oxmysql_not_started'
        print('^1[armasvip] ERROR: oxmysql no está iniciado. ArmasVIP no ejecutará consultas hasta corregir el orden de arranque.^0')
        return
    end

    local ok, err = pcall(function()
        createSchema()
        reloadCache()
    end)

    if not ok then
        bootstrapError = tostring(err)
        ready = false
        print(('^1[armasvip] ERROR durante inicialización SQL: %s^0'):format(bootstrapError))
        print('^3[armasvip] El recurso queda cargado pero deshabilita grants para evitar un crash en cadena. Revisa oxmysql/SQL.^0')
        return
    end

    CreateThread(function()
        Wait(15000)
        for _, value in ipairs(GetPlayers()) do
            local playerSource = tonumber(value)
            if playerSource then
                local cleanupOk, cleanupErr = pcall(ArmasVipGrants.CleanupInventory, playerSource)
                if not cleanupOk then
                    print(('^3[armasvip] Aviso cleanup jugador %s: %s^0'):format(playerSource, cleanupErr))
                end
            end
        end
    end)

    while true do
        Wait(math.max(10, tonumber(Config.Grants.ExpiryCheckSeconds) or 60) * 1000)

        local expiryOk, expiryErr = pcall(function()
            local expired = MySQL.query.await([[
                SELECT id, owner_key, owner_name, weapon, components, tint, assigned_by,
                       assigned_by_name, assigned_at, expires_at, status, initial_delivered
                FROM armasvip_grants
                WHERE status = 'active' AND expires_at IS NOT NULL AND expires_at <= NOW()
            ]]) or {}

            for _, row in ipairs(expired) do
                local grant = normalize(row)
                removePhysicalItem(grant)
                MySQL.update.await(
                    "UPDATE armasvip_grants SET status = 'expired' WHERE id = ? AND status = 'active'",
                    { grant.id }
                )
                uncacheGrant(grant.id)
            end
        end)

        if not expiryOk then
            print(('^3[armasvip] Aviso comprobando expiraciones: %s^0'):format(expiryErr))
        end
    end
end)

function ArmasVipGrants.IsReady()
    return ready, bootstrapError
end
