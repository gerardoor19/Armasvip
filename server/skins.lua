ArmasVipSkinState = ArmasVipSkinState or {}

local ready = false
local activeByGrant = {}
local unlocksByGrant = {}

local function waitReady()
    local deadline = GetGameTimer() + 10000
    while not ready and GetGameTimer() < deadline do Wait(0) end
    return ready
end

local function configuredDefaults(weaponName)
    local unlocked = {}
    for _, skinId in ipairs((Config.Skins and Config.Skins.DefaultUnlocked) or { ArmasVipSkins.Default }) do
        if ArmasVipSkins.IsCompatible(weaponName, skinId) then unlocked[skinId] = true end
    end
    unlocked[ArmasVipSkins.Default] = true
    return unlocked
end

local function loadUnlocks(grant)
    if unlocksByGrant[grant.id] then return unlocksByGrant[grant.id] end

    local unlocked = configuredDefaults(grant.weapon)
    local rows = MySQL.query.await([[
        SELECT cosmetic_value
        FROM armasvip_cosmetics
        WHERE grant_id = ? AND cosmetic_type = 'skin'
    ]], { grant.id }) or {}

    for _, row in ipairs(rows) do
        local skinId = tostring(row.cosmetic_value or '')
        if ArmasVipSkins.IsCompatible(grant.weapon, skinId) then unlocked[skinId] = true end
    end

    unlocksByGrant[grant.id] = unlocked
    return unlocked
end

local function loadActive(grant)
    if activeByGrant[grant.id] then return activeByGrant[grant.id] end

    local rows = MySQL.query.await('SELECT skin_id FROM armasvip_skin_state WHERE grant_id = ? LIMIT 1', { grant.id }) or {}
    local skinId = rows[1] and tostring(rows[1].skin_id or '') or ArmasVipSkins.Default
    local unlocked = loadUnlocks(grant)

    if not unlocked[skinId] or not ArmasVipSkins.IsCompatible(grant.weapon, skinId) then
        skinId = ArmasVipSkins.Default
    end

    activeByGrant[grant.id] = skinId
    return skinId
end

local function sortedUnlocks(grant)
    local values = {}
    for skinId in pairs(loadUnlocks(grant)) do values[#values + 1] = skinId end
    table.sort(values)
    return values
end

local function publicCatalog()
    local output = {}
    for _, skin in ipairs(ArmasVipSkins.Catalog) do
        output[#output + 1] = {
            id = skin.id,
            label = locale(skin.labelKey),
            description = locale(skin.descriptionKey),
            rarity = skin.rarity,
            animated = skin.animated == true,
            weapons = skin.weapons,
            source = skin.source,
        }
    end
    return output
end

local function stateForGrant(grant)
    return {
        activeSkin = loadActive(grant),
        unlockedSkins = sortedUnlocks(grant),
        supported = ArmasVipSkins.GetTexture(grant.weapon) ~= nil,
    }
end

local function ownedGrant(source, grantId)
    local identity = ArmasVipIdentity.Get(source)
    if not identity then return nil, 'invalid_identity' end

    local grant = ArmasVipGrants.Get(grantId)
    if not grant or grant.owner_key ~= identity.key then return nil, 'grant_not_found' end
    return grant
end

function ArmasVipSkinState.GetPlayerContext(source)
    if not waitReady() then return nil, 'database_not_ready' end
    local identity = ArmasVipIdentity.Get(source)
    if not identity then return nil, 'invalid_identity' end

    local states = {}
    for _, publicGrant in ipairs(ArmasVipGrants.GetOwner(identity.key)) do
        local grant = ArmasVipGrants.Get(publicGrant.id)
        if grant then states[tostring(grant.id)] = stateForGrant(grant) end
    end

    return { catalog = publicCatalog(), states = states }
end

function ArmasVipSkinState.GetAdminContext(source)
    if not isAllowed(source) then return nil, 'no_permission' end
    if not waitReady() then return nil, 'database_not_ready' end

    local grants = ArmasVipGrants.GetAll()
    for _, publicGrant in ipairs(grants) do
        local grant = ArmasVipGrants.Get(publicGrant.id)
        if grant then
            local state = stateForGrant(grant)
            publicGrant.activeSkin = state.activeSkin
            publicGrant.unlockedSkins = state.unlockedSkins
            publicGrant.skinSupported = state.supported
        end
    end

    return { grants = grants, catalog = publicCatalog() }
end

function ArmasVipSkinState.GetActiveForPlayer(source, grantId)
    if not waitReady() then return false, 'database_not_ready' end
    local grant, reason = ownedGrant(source, grantId)
    if not grant then return false, reason end

    return true, {
        skin = loadActive(grant),
        supported = ArmasVipSkins.GetTexture(grant.weapon) ~= nil,
        weapon = grant.weapon,
    }
end

function ArmasVipSkinState.SetActive(source, grantId, skinId)
    if not waitReady() then return false, 'database_not_ready' end
    local grant, reason = ownedGrant(source, grantId)
    if not grant then return false, reason end

    skinId = tostring(skinId or '')
    if not ArmasVipSkins.Get(skinId) then return false, 'skin_invalid' end
    if not ArmasVipSkins.IsCompatible(grant.weapon, skinId) then return false, 'skin_not_compatible' end
    if not loadUnlocks(grant)[skinId] then return false, 'skin_locked' end

    MySQL.query.await([[
        INSERT INTO armasvip_skin_state (grant_id, skin_id, updated_at)
        VALUES (?, ?, CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE skin_id = VALUES(skin_id), updated_at = CURRENT_TIMESTAMP
    ]], { grant.id, skinId })

    activeByGrant[grant.id] = skinId
    TriggerClientEvent('armasvip:client:applyVipSkin', source, grant.id, grant.weapon, skinId)
    return true, stateForGrant(grant)
end

function ArmasVipSkinState.SetUnlocked(adminSource, grantId, skinId, unlocked)
    if not isAllowed(adminSource) then return false, 'no_permission' end
    if not waitReady() then return false, 'database_not_ready' end

    local grant = ArmasVipGrants.Get(grantId)
    if not grant then return false, 'grant_not_found' end

    skinId = tostring(skinId or '')
    if not ArmasVipSkins.Get(skinId) then return false, 'skin_invalid' end
    if not ArmasVipSkins.IsCompatible(grant.weapon, skinId) then return false, 'skin_not_compatible' end

    local defaults = configuredDefaults(grant.weapon)
    if not unlocked and defaults[skinId] then return false, 'skin_required' end

    local admin = ArmasVipIdentity.Get(adminSource)
    local unlockedBy = admin and admin.key or ('source:%s'):format(adminSource)

    if unlocked then
        MySQL.insert.await([[
            INSERT IGNORE INTO armasvip_cosmetics (grant_id, cosmetic_type, cosmetic_value, unlocked_by)
            VALUES (?, 'skin', ?, ?)
        ]], { grant.id, skinId, unlockedBy })
    else
        MySQL.query.await([[
            DELETE FROM armasvip_cosmetics
            WHERE grant_id = ? AND cosmetic_type = 'skin' AND cosmetic_value = ?
        ]], { grant.id, skinId })
    end

    unlocksByGrant[grant.id] = nil
    local refreshed = loadUnlocks(grant)

    if not refreshed[loadActive(grant)] then
        activeByGrant[grant.id] = ArmasVipSkins.Default
        MySQL.query.await([[
            INSERT INTO armasvip_skin_state (grant_id, skin_id, updated_at)
            VALUES (?, ?, CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE skin_id = VALUES(skin_id), updated_at = CURRENT_TIMESTAMP
        ]], { grant.id, ArmasVipSkins.Default })

        local target = ArmasVipIdentity.FindOnlineByKey(grant.owner_key)
        if target then TriggerClientEvent('armasvip:client:applyVipSkin', target, grant.id, grant.weapon, ArmasVipSkins.Default) end
    end

    return true, stateForGrant(grant)
end

lib.callback.register('armasvip:getSkinContext', function(source)
    local context, reason = ArmasVipSkinState.GetPlayerContext(source)
    if not context then return { ok = false, reason = reason } end
    context.ok = true
    return context
end)

lib.callback.register('armasvip:getEquippedSkin', function(source, grantId)
    local ok, result = ArmasVipSkinState.GetActiveForPlayer(source, grantId)
    if not ok then return { ok = false, reason = result } end
    result.ok = true
    return result
end)

lib.callback.register('armasvip:setActiveSkin', function(source, payload)
    if type(payload) ~= 'table' then return { ok = false, reason = 'invalid_payload' } end
    local ok, result = ArmasVipSkinState.SetActive(source, payload.grantId, payload.skinId)
    if not ok then return { ok = false, reason = result } end
    return { ok = true, state = result }
end)

lib.callback.register('armasvip:getAdminSkinContext', function(source)
    local context, reason = ArmasVipSkinState.GetAdminContext(source)
    if not context then return { ok = false, reason = reason } end
    context.ok = true
    return context
end)

lib.callback.register('armasvip:setSkinUnlock', function(source, payload)
    if type(payload) ~= 'table' then return { ok = false, reason = 'invalid_payload' } end
    local ok, result = ArmasVipSkinState.SetUnlocked(source, payload.grantId, payload.skinId, payload.unlocked == true)
    if not ok then return { ok = false, reason = result } end
    return { ok = true, state = result }
end)

CreateThread(function()
    local deadline = GetGameTimer() + 30000
    while GetResourceState('oxmysql') ~= 'started' and GetGameTimer() < deadline do Wait(250) end
    if GetResourceState('oxmysql') ~= 'started' then return end

    local ok, err = pcall(function()
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `armasvip_skin_state` (
                `grant_id` BIGINT UNSIGNED NOT NULL,
                `skin_id` VARCHAR(80) NOT NULL DEFAULT 'default',
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`grant_id`),
                KEY `idx_armasvip_skin_id` (`skin_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ]])
    end)

    if not ok then
        print(('^1[armasvip] Weapon Studio SQL error: %s^0'):format(tostring(err)))
        return
    end

    ready = true
end)
