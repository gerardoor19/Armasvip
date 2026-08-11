local menuOpen = false

local uiTranslationKeys = {
    'ui_exclusive_arsenal', 'ui_weapons', 'ui_close', 'ui_categories', 'ui_search_placeholder',
    'ui_empty_title', 'ui_empty_subtitle', 'ui_no_weapon_selected', 'ui_select_weapon_hint',
    'ui_no_components', 'ui_tint', 'ui_selection_success', 'ui_selection_failed',
    'ui_opening_assignment', 'ui_assign_weapon', 'ui_component_magazine', 'ui_component_flashlight',
    'ui_component_muzzle', 'ui_component_grip', 'ui_component_barrel', 'ui_component_sight',
    'ui_component_skin', 'ui_component_other', 'ui_owned_my_arsenal', 'ui_owned_personal_collection',
    'ui_owned_owner_default', 'ui_owned_weapon_singular', 'ui_owned_weapon_plural', 'ui_owned_your_weapons',
    'ui_owned_in_inventory', 'ui_owned_available', 'ui_owned_permanent_notice', 'ui_owned_selected_weapon',
    'ui_owned_close', 'ui_owned_current_inventory', 'ui_owned_available_withdraw', 'ui_owned_property',
    'ui_owned_permanent_nontransferable', 'ui_owned_durability', 'ui_owned_no_wear',
    'ui_owned_installed_components', 'ui_owned_no_components_current', 'ui_owned_components_not_restored',
    'ui_owned_components_first_delivery', 'ui_owned_in_inventory_button', 'ui_owned_withdrawing',
    'ui_owned_withdraw_weapon', 'ui_owned_customization', 'ui_owned_camos_finishes', 'ui_owned_camos_help',
    'ui_owned_collection', 'ui_owned_unlocked', 'ui_owned_equipped', 'ui_owned_locked',
    'ui_owned_active_finish', 'ui_owned_default', 'ui_owned_withdraw_success', 'ui_owned_already_inventory',
    'ui_owned_withdraw_failed', 'ui_owned_tint_saved', 'ui_owned_tint_locked', 'ui_owned_tint_failed',
}

local function buildUiTranslations()
    local translations = {}
    for _, key in ipairs(uiTranslationKeys) do translations[key] = locale(key) end
    return translations
end

local function localizedCategories()
    local categories = {}
    for _, category in ipairs(ArmasVipData.categories) do
        categories[#categories + 1] = {
            id = category.id,
            label = locale('category_' .. category.id),
            icon = category.icon,
        }
    end
    return categories
end

---@return { index: number, label: string }[]
local function buildTints()
    local tints = {}
    for _, index in ipairs(Config.TintIndexes) do
        tints[#tints + 1] = { index = index, label = locale('tint_' .. index) }
    end
    return tints
end

local function closeMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function baseNuiPayload()
    return {
        components = ArmasVipData.components,
        tints = buildTints(),
        imageBase = 'nui://ox_inventory/web/images/',
        translations = buildUiTranslations(),
    }
end

local function openAdminMenu()
    if menuOpen then return end

    local payload = baseNuiPayload()
    payload.categories = localizedCategories()
    payload.weapons = ArmasVipData.weapons

    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = payload })
end

local function expiryLabel(value)
    if not value then return locale('duration_permanent') end
    return locale('expires_at', tostring(value))
end

local function componentSummary(components)
    if type(components) ~= 'table' or #components == 0 then return locale('no_components') end

    local labels = {}
    for _, name in ipairs(components) do
        labels[#labels + 1] = (ArmasVipData.components[name] and ArmasVipData.components[name].label) or name
    end
    return table.concat(labels, ', ')
end

local function ownedPayload(context)
    local payload = baseNuiPayload()
    payload.ownerName = context.ownerName
    payload.grants = context.grants or {}
    return payload
end

local function showOwnedMenu()
    if menuOpen then return end

    local context = lib.callback.await('armasvip:getMyGrants', false)
    if not context or context.identityError then
        lib.notify({ title = locale('notify_title'), description = locale('identity_failed'), type = 'error' })
        return
    end

    local grants = context.grants or {}
    if #grants == 0 then
        lib.notify({ title = locale('notify_title'), description = locale('no_vip_weapons'), type = 'inform' })
        return
    end

    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openOwned', data = ownedPayload(context) })
end

local function showGrantManager()
    local grants = lib.callback.await('armasvip:getAdminGrants', false)
    if grants == nil then
        lib.notify({ title = locale('notify_title'), description = locale('no_permission_short'), type = 'error' })
        return
    end

    local options = {}
    for _, grant in ipairs(grants) do
        local current = grant
        local ownerName = current.ownerName or locale('player_fallback')
        options[#options + 1] = {
            title = ('%s · %s'):format(ownerName, current.label),
            description = expiryLabel(current.expiresAt),
            icon = 'gun',
            iconColor = '#ff7a00',
            metadata = {
                { label = locale('initial_components'), value = componentSummary(current.components) },
                { label = locale('active_camo'), value = locale('tint_' .. tostring(current.tint or 0)) },
                { label = locale('unlocked_camos'), value = #(current.unlockedTints or {}) },
                { label = 'Grant ID', value = current.id },
            },
            onSelect = function()
                local actionId = ('armasvip_grant_actions_%s'):format(current.id)
                lib.registerContext({
                    id = actionId,
                    title = ('%s · %s'):format(ownerName, current.label),
                    menu = 'armasvip_manage_grants',
                    options = {
                        {
                            title = locale('manage_camos'),
                            description = locale('manage_camos_description'),
                            icon = 'palette',
                            onSelect = function()
                                local tintOptions = {}
                                local unlocked = {}
                                for _, value in ipairs(current.unlockedTints or {}) do unlocked[tonumber(value)] = true end

                                for _, tint in ipairs(buildTints()) do
                                    local isUnlocked = unlocked[tint.index] == true
                                    local tintValue = tint
                                    tintOptions[#tintOptions + 1] = {
                                        title = tintValue.label,
                                        description = isUnlocked and locale('unlocked') or locale('locked'),
                                        icon = isUnlocked and 'lock-open' or 'lock',
                                        iconColor = isUnlocked and '#22c55e' or '#9aa0ad',
                                        onSelect = function()
                                            local result = lib.callback.await('armasvip:setTintUnlock', false, {
                                                grantId = current.id,
                                                tint = tintValue.index,
                                                unlocked = not isUnlocked,
                                            })
                                            if result and result.ok then
                                                lib.notify({
                                                    title = locale('notify_title'),
                                                    description = isUnlocked and locale('camo_removed') or locale('camo_unlocked'),
                                                    type = 'success',
                                                })
                                                showGrantManager()
                                            else
                                                local reason = result and result.reason
                                                lib.notify({
                                                    title = locale('notify_title'),
                                                    description = reason == 'default_tint' and locale('default_tint_required') or locale('camo_modify_failed'),
                                                    type = 'error',
                                                })
                                            end
                                        end,
                                    }
                                end

                                local tintMenuId = ('armasvip_grant_tints_%s'):format(current.id)
                                lib.registerContext({ id = tintMenuId, title = locale('unlocked_camos'), menu = actionId, options = tintOptions })
                                lib.showContext(tintMenuId)
                            end,
                        },
                        {
                            title = locale('revoke_vip_weapon'),
                            description = locale('revoke_vip_weapon_description'),
                            icon = 'trash',
                            iconColor = '#ef4444',
                            onSelect = function()
                                local answer = lib.alertDialog({
                                    header = locale('revoke_vip_weapon'),
                                    content = locale('revoke_confirm', current.label, ownerName),
                                    centered = true,
                                    cancel = true,
                                })
                                if answer ~= 'confirm' then return end

                                local result = lib.callback.await('armasvip:revokeGrant', false, current.id)
                                if result and result.ok then
                                    lib.notify({ title = locale('notify_title'), description = locale('grant_revoked'), type = 'success' })
                                    showGrantManager()
                                else
                                    lib.notify({ title = locale('notify_title'), description = locale('grant_revoke_failed'), type = 'error' })
                                end
                            end,
                        },
                    },
                })
                lib.showContext(actionId)
            end,
        }
    end

    if #options == 0 then
        options[1] = { title = locale('no_active_grants'), description = locale('no_active_grants_description'), icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'armasvip_manage_grants', title = locale('manage_vip_weapons'), options = options })
    lib.showContext('armasvip_manage_grants')
end

local function durationLabel(duration)
    if duration.labelKey then return locale(duration.labelKey) end
    if tonumber(duration.days) == 0 then return locale('duration_permanent') end
    return locale('duration_days', tonumber(duration.days) or 0)
end

local function assignSelectedWeapon(data)
    local context = lib.callback.await('armasvip:getAdminContext', false)
    if not context then
        lib.notify({ title = locale('notify_title'), description = locale('no_permission_short'), type = 'error' })
        return
    end

    local playerOptions = {}
    for _, player in ipairs(context.players or {}) do
        playerOptions[#playerOptions + 1] = { value = tostring(player.source), label = ('[%s] %s'):format(player.source, player.name) }
    end

    if #playerOptions == 0 then
        lib.notify({ title = locale('notify_title'), description = locale('no_players_online'), type = 'error' })
        Wait(100)
        openAdminMenu()
        return
    end

    local durationOptions = {}
    for _, duration in ipairs(context.durations or {}) do
        durationOptions[#durationOptions + 1] = { value = tostring(duration.days), label = durationLabel(duration) }
    end

    local input = lib.inputDialog(locale('assign_vip_weapon'), {
        {
            type = 'select',
            label = locale('player'),
            description = locale('persistent_identity_description'),
            options = playerOptions,
            searchable = true,
            required = true,
        },
        {
            type = 'select',
            label = locale('duration'),
            options = durationOptions,
            default = durationOptions[1] and durationOptions[1].value or '0',
            required = true,
        },
    }, { size = 'md' })

    if not input then
        Wait(100)
        openAdminMenu()
        return
    end

    local payload = {
        targetSource = tonumber(input[1]),
        durationDays = tonumber(input[2]) or 0,
        weapon = data.weapon,
        components = data.components,
        tint = data.tint,
    }

    local result = lib.callback.await('armasvip:createGrant', false, payload)
    if not result or not result.ok then
        local reasonKey = 'reason_' .. tostring(result and result.reason or 'unknown')
        lib.notify({ title = locale('notify_title'), description = locale(reasonKey), type = 'error' })
    end

    Wait(100)
    openAdminMenu()
end

RegisterNetEvent('armasvip:open', openAdminMenu)
RegisterNetEvent('armasvip:openAdmin', openAdminMenu)
RegisterNetEvent('armasvip:openOwned', showOwnedMenu)
RegisterNetEvent('armasvip:manage', showGrantManager)

RegisterNUICallback('armasvip:close', function(_, cb)
    closeMenu()
    cb(true)
end)

RegisterNUICallback('armasvip:equip', function(data, cb)
    closeMenu()
    cb(true)
    CreateThread(function() assignSelectedWeapon(data) end)
end)

RegisterNUICallback('armasvip:ownedEquip', function(data, cb)
    local result = lib.callback.await('armasvip:equipGrant', false, data and data.grantId)
    local context = lib.callback.await('armasvip:getMyGrants', false)
    cb({ ok = result and result.ok == true, reason = result and result.reason, context = context and ownedPayload(context) or nil })
end)

RegisterNUICallback('armasvip:ownedSetTint', function(data, cb)
    local result = lib.callback.await('armasvip:setActiveTint', false, data)
    local context = lib.callback.await('armasvip:getMyGrants', false)
    cb({ ok = result and result.ok == true, reason = result and result.reason, context = context and ownedPayload(context) or nil })
end)

CreateThread(function()
    Wait(15000)
    TriggerServerEvent('armasvip:server:cleanup')
end)
