local currentWeapon = nil
local applyToken = 0
local activeReplacement = nil
local runtimeEngine = nil

local skinTranslationKeys = {
    'ui_skin_studio', 'ui_skin_studio_subtitle', 'ui_skin_open', 'ui_skin_close',
    'ui_skin_collection', 'ui_skin_animated', 'ui_skin_static', 'ui_skin_equipped',
    'ui_skin_locked', 'ui_skin_apply', 'ui_skin_saved', 'ui_skin_failed',
    'ui_skin_not_supported', 'ui_skin_inspect_hint', 'ui_skin_rarity_common',
    'ui_skin_rarity_rare', 'ui_skin_rarity_epic', 'ui_skin_rarity_legendary',
}

local function skinConfig()
    return type(Config.Skins) == 'table' and Config.Skins or {}
end

local function uiTranslations()
    local result = {}
    for _, key in ipairs(skinTranslationKeys) do result[key] = locale(key) end
    return result
end

local function localNuiUrl(path)
    local clean = tostring(path or ''):gsub('^/', '')
    return ('https://cfx-nui-%s/web/dist/%s'):format(GetCurrentResourceName(), clean)
end

local function parkRuntimeEngine()
    if not runtimeEngine or not runtimeEngine.dui or not IsDuiAvailable(runtimeEngine.dui) then return end

    local idleUrl = localNuiUrl('skin-renderer.html?preset=carbon')
    if runtimeEngine.url ~= idleUrl then
        SetDuiUrl(runtimeEngine.dui, idleUrl)
        runtimeEngine.url = idleUrl
    end
end

local function clearReplacement(parkRenderer)
    if activeReplacement then
        RemoveReplaceTexture(activeReplacement.ytd, activeReplacement.texture)
        activeReplacement = nil
    end

    if parkRenderer == true then parkRuntimeEngine() end
end

local function destroyRuntimeEngine()
    clearReplacement(false)

    if runtimeEngine and runtimeEngine.dui then
        DestroyDui(runtimeEngine.dui)
    end

    runtimeEngine = nil
end

local function skinUrl(skin)
    local source = skin and skin.source
    if type(source) ~= 'table' then return nil end

    if source.type == 'procedural' then
        return localNuiUrl(('skin-renderer.html?preset=%s'):format(tostring(source.preset or 'carbon')))
    end

    if source.type == 'asset' and type(source.path) == 'string' and source.path ~= '' then
        return localNuiUrl(source.path)
    end

    if source.type == 'url' and skinConfig().AllowExternalUrls == true then
        return source.url
    end

    return nil
end

local function ensureRuntimeEngine(url)
    if runtimeEngine and runtimeEngine.dui and IsDuiAvailable(runtimeEngine.dui) then
        if runtimeEngine.url ~= url then
            SetDuiUrl(runtimeEngine.dui, url)
            runtimeEngine.url = url
        end
        return runtimeEngine
    end

    if runtimeEngine and runtimeEngine.dui then
        DestroyDui(runtimeEngine.dui)
        runtimeEngine = nil
    end

    local settings = skinConfig()
    local size = math.max(128, math.min(1024, tonumber(settings.TextureSize) or 512))
    local dui = CreateDui(url, size, size)
    local timeout = GetGameTimer() + math.max(1000, tonumber(settings.DuiTimeoutMs) or 5000)

    while dui and not IsDuiAvailable(dui) and GetGameTimer() < timeout do Wait(0) end
    if not dui or not IsDuiAvailable(dui) then
        if dui then DestroyDui(dui) end
        return nil
    end

    -- One runtime TXD/DUI pair is reused for the whole resource lifetime. Creating
    -- a fresh TXD on every skin switch would leave dictionaries resident in the
    -- client session because FiveM has no matching DestroyRuntimeTxd native.
    local runtimeTxdName = ('armasvip_skin_runtime_%s'):format(GetGameTimer())
    local runtimeTxd = CreateRuntimeTxd(runtimeTxdName)
    if not runtimeTxd then
        DestroyDui(dui)
        return nil
    end

    local handle = GetDuiHandle(dui)
    local runtimeTexture = CreateRuntimeTextureFromDuiHandle(runtimeTxd, 'skin', handle)
    if not runtimeTexture then
        DestroyDui(dui)
        return nil
    end

    runtimeEngine = {
        dui = dui,
        url = url,
        txdName = runtimeTxdName,
        textureName = 'skin',
    }

    return runtimeEngine
end

local function applyRuntimeSkin(weaponName, skinId)
    local settings = skinConfig()
    if settings.Enabled == false then
        clearReplacement(true)
        return false
    end

    weaponName = type(weaponName) == 'string' and weaponName:upper() or nil
    local skin = ArmasVipSkins.Get(skinId)
    local mapping = weaponName and ArmasVipSkins.GetTexture(weaponName) or nil

    if not skin or skin.id == ArmasVipSkins.Default then
        clearReplacement(true)
        return true
    end

    if not mapping or not ArmasVipSkins.IsCompatible(weaponName, skin.id) then
        clearReplacement(true)
        return false
    end

    if activeReplacement
        and activeReplacement.weapon == weaponName
        and activeReplacement.skinId == skin.id then
        return true
    end

    local url = skinUrl(skin)
    if not url then
        clearReplacement(true)
        return false
    end

    clearReplacement(false)

    local engine = ensureRuntimeEngine(url)
    if not engine then return false end

    AddReplaceTexture(mapping.ytd, mapping.texture, engine.txdName, engine.textureName)

    activeReplacement = {
        weapon = weaponName,
        skinId = skin.id,
        ytd = mapping.ytd,
        texture = mapping.texture,
    }

    return true
end

local function refreshCurrentSkin()
    applyToken = applyToken + 1
    local token = applyToken
    local weapon = currentWeapon

    if not weapon or type(weapon.metadata) ~= 'table' or weapon.metadata.armasvip ~= true then
        clearReplacement(true)
        return
    end

    local grantId = tonumber(weapon.metadata.vipGrantId)
    if not grantId then
        clearReplacement(true)
        return
    end

    CreateThread(function()
        Wait(120)
        local response = lib.callback.await('armasvip:getEquippedSkin', false, grantId)
        if token ~= applyToken then return end
        if not currentWeapon or tonumber(currentWeapon.metadata and currentWeapon.metadata.vipGrantId) ~= grantId then return end

        if not response or response.ok ~= true or response.supported ~= true then
            clearReplacement(true)
            return
        end

        applyRuntimeSkin(response.weapon or currentWeapon.name, response.skin or ArmasVipSkins.Default)
    end)
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    currentWeapon = weapon
    refreshCurrentSkin()
end)

-- ox_inventory may already have a weapon equipped when only ArmasVIP is restarted.
-- Bootstrap the current slot so persistence works without forcing a re-equip.
CreateThread(function()
    Wait(1000)
    if GetResourceState('ox_inventory') ~= 'started' then return end

    currentWeapon = exports.ox_inventory:getCurrentWeapon()
    refreshCurrentSkin()
end)

RegisterNetEvent('armasvip:client:applyVipSkin', function(grantId, weaponName, skinId)
    grantId = tonumber(grantId)
    if not currentWeapon or not grantId then return end
    if tonumber(currentWeapon.metadata and currentWeapon.metadata.vipGrantId) ~= grantId then return end
    applyRuntimeSkin(weaponName or currentWeapon.name, skinId or ArmasVipSkins.Default)
end)

RegisterNUICallback('armasvip:getSkinContext', function(_, cb)
    local response = lib.callback.await('armasvip:getSkinContext', false)
    response = type(response) == 'table' and response or { ok = false, reason = 'unknown' }
    response.translations = uiTranslations()
    cb(response)
end)

RegisterNUICallback('armasvip:ownedSetSkin', function(data, cb)
    local response = lib.callback.await('armasvip:setActiveSkin', false, data)
    cb(type(response) == 'table' and response or { ok = false, reason = 'unknown' })
end)

local function compatibleCatalog(weaponName, catalog)
    local output = {}
    for _, skin in ipairs(catalog or {}) do
        if ArmasVipSkins.IsCompatible(weaponName, skin.id) then output[#output + 1] = skin end
    end
    return output
end

local function showAdminSkinManager()
    local context = lib.callback.await('armasvip:getAdminSkinContext', false)
    if not context or context.ok ~= true then
        lib.notify({ title = locale('notify_title'), description = locale('no_permission_short'), type = 'error' })
        return
    end

    local grantOptions = {}
    for _, grant in ipairs(context.grants or {}) do
        local current = grant
        grantOptions[#grantOptions + 1] = {
            title = ('%s · %s'):format(current.ownerName or locale('player_fallback'), current.label),
            description = current.skinSupported and locale('manage_skins_description') or locale('skin_not_compatible'),
            icon = 'palette',
            disabled = current.skinSupported ~= true,
            onSelect = function()
                local unlocked = {}
                for _, value in ipairs(current.unlockedSkins or {}) do unlocked[value] = true end

                local skinOptions = {}
                for _, skin in ipairs(compatibleCatalog(current.weapon, context.catalog)) do
                    local skinValue = skin
                    local isUnlocked = unlocked[skinValue.id] == true
                    local isRequired = false
                    for _, defaultId in ipairs(skinConfig().DefaultUnlocked or {}) do
                        if defaultId == skinValue.id then isRequired = true break end
                    end
                    if skinValue.id == ArmasVipSkins.Default then isRequired = true end

                    skinOptions[#skinOptions + 1] = {
                        title = skinValue.label,
                        description = isUnlocked and locale('unlocked') or locale('locked'),
                        icon = skinValue.animated and 'wand-magic-sparkles' or 'palette',
                        iconColor = isUnlocked and '#22c55e' or '#9aa0ad',
                        onSelect = function()
                            if isRequired and isUnlocked then
                                lib.notify({ title = locale('notify_title'), description = locale('skin_default_required'), type = 'error' })
                                return
                            end

                            local result = lib.callback.await('armasvip:setSkinUnlock', false, {
                                grantId = current.id,
                                skinId = skinValue.id,
                                unlocked = not isUnlocked,
                            })

                            if result and result.ok then
                                lib.notify({
                                    title = locale('notify_title'),
                                    description = isUnlocked and locale('skin_removed') or locale('skin_unlocked'),
                                    type = 'success',
                                })
                                showAdminSkinManager()
                            else
                                lib.notify({ title = locale('notify_title'), description = locale('skin_modify_failed'), type = 'error' })
                            end
                        end,
                    }
                end

                local menuId = ('armasvip_skin_grant_%s'):format(current.id)
                lib.registerContext({ id = menuId, title = current.label, menu = 'armasvip_skin_manager', options = skinOptions })
                lib.showContext(menuId)
            end,
        }
    end

    if #grantOptions == 0 then
        grantOptions[1] = { title = locale('no_active_grants'), description = locale('no_active_grants_description'), readOnly = true }
    end

    lib.registerContext({ id = 'armasvip_skin_manager', title = locale('manage_skins'), options = grantOptions })
    lib.showContext('armasvip_skin_manager')
end

RegisterNetEvent('armasvip:manageSkins', showAdminSkinManager)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    destroyRuntimeEngine()
end)
