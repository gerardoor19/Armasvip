local currentWeapon = nil
local applyToken = 0
local activeReplacement = nil

local skinTranslationKeys = {
    'ui_skin_studio', 'ui_skin_studio_subtitle', 'ui_skin_open', 'ui_skin_close',
    'ui_skin_collection', 'ui_skin_animated', 'ui_skin_static', 'ui_skin_equipped',
    'ui_skin_locked', 'ui_skin_apply', 'ui_skin_saved', 'ui_skin_failed',
    'ui_skin_not_supported', 'ui_skin_inspect_hint', 'ui_skin_rarity_common',
    'ui_skin_rarity_rare', 'ui_skin_rarity_epic', 'ui_skin_rarity_legendary',
}

local function uiTranslations()
    local result = {}
    for _, key in ipairs(skinTranslationKeys) do result[key] = locale(key) end
    return result
end

local function clearReplacement()
    if not activeReplacement then return end

    AddReplaceTexture(
        activeReplacement.ytd,
        activeReplacement.texture,
        activeReplacement.ytd,
        activeReplacement.texture
    )

    if activeReplacement.dui and IsDuiAvailable(activeReplacement.dui) then
        DestroyDui(activeReplacement.dui)
    end

    activeReplacement = nil
end

local function localNuiUrl(path)
    return ('https://cfx-nui-%s/%s'):format(GetCurrentResourceName(), path:gsub('^/', ''))
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

    if source.type == 'url' and Config.Skins.AllowExternalUrls == true then
        return source.url
    end

    return nil
end

local function applyRuntimeSkin(weaponName, skinId)
    if Config.Skins.Enabled == false then
        clearReplacement()
        return false
    end

    weaponName = type(weaponName) == 'string' and weaponName:upper() or nil
    local skin = ArmasVipSkins.Get(skinId)
    local mapping = weaponName and ArmasVipSkins.GetTexture(weaponName) or nil

    if not skin or skin.id == ArmasVipSkins.Default then
        clearReplacement()
        return true
    end

    if not mapping or not ArmasVipSkins.IsCompatible(weaponName, skin.id) then
        clearReplacement()
        return false
    end

    if activeReplacement
        and activeReplacement.weapon == weaponName
        and activeReplacement.skinId == skin.id then
        return true
    end

    clearReplacement()

    local url = skinUrl(skin)
    if not url then return false end

    local size = math.max(128, math.min(1024, tonumber(Config.Skins.TextureSize) or 512))
    local dui = CreateDui(url, size, size)
    local timeout = GetGameTimer() + math.max(1000, tonumber(Config.Skins.DuiTimeoutMs) or 5000)

    while dui and not IsDuiAvailable(dui) and GetGameTimer() < timeout do Wait(0) end
    if not dui or not IsDuiAvailable(dui) then
        if dui then DestroyDui(dui) end
        return false
    end

    local runtimeTxdName = ('armasvip_skin_%s'):format(GetGameTimer())
    local runtimeTxd = CreateRuntimeTxd(runtimeTxdName)
    local handle = GetDuiHandle(dui)
    CreateRuntimeTextureFromDuiHandle(runtimeTxd, 'skin', handle)
    AddReplaceTexture(mapping.ytd, mapping.texture, runtimeTxdName, 'skin')

    activeReplacement = {
        weapon = weaponName,
        skinId = skin.id,
        ytd = mapping.ytd,
        texture = mapping.texture,
        dui = dui,
        runtimeTxdName = runtimeTxdName,
    }

    return true
end

local function refreshCurrentSkin()
    applyToken = applyToken + 1
    local token = applyToken
    local weapon = currentWeapon

    if not weapon or type(weapon.metadata) ~= 'table' or weapon.metadata.armasvip ~= true then
        clearReplacement()
        return
    end

    local grantId = tonumber(weapon.metadata.vipGrantId)
    if not grantId then
        clearReplacement()
        return
    end

    CreateThread(function()
        Wait(120)
        local response = lib.callback.await('armasvip:getEquippedSkin', false, grantId)
        if token ~= applyToken then return end
        if not currentWeapon or tonumber(currentWeapon.metadata and currentWeapon.metadata.vipGrantId) ~= grantId then return end

        if not response or response.ok ~= true or response.supported ~= true then
            clearReplacement()
            return
        end

        applyRuntimeSkin(response.weapon or currentWeapon.name, response.skin or ArmasVipSkins.Default)
    end)
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    currentWeapon = weapon
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
                    for _, defaultId in ipairs(Config.Skins.DefaultUnlocked or {}) do
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
    clearReplacement()
end)
