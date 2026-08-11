local menuOpen = false

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

local function openAdminMenu()
    if menuOpen then return end

    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data = {
            categories = ArmasVipData.categories,
            weapons = ArmasVipData.weapons,
            components = ArmasVipData.components,
            tints = buildTints(),
            imageBase = 'nui://ox_inventory/web/images/',
        },
    })
end

local function expiryLabel(value)
    if not value then return 'Permanente' end
    return ('Expira: %s'):format(tostring(value))
end

local function componentSummary(components)
    if type(components) ~= 'table' or #components == 0 then return 'Sin accesorios' end

    local labels = {}
    for _, name in ipairs(components) do
        labels[#labels + 1] = (ArmasVipData.components[name] and ArmasVipData.components[name].label) or name
    end

    return table.concat(labels, ', ')
end

local function ownedPayload(context)
    return {
        ownerName = context.ownerName,
        grants = context.grants or {},
        components = ArmasVipData.components,
        tints = buildTints(),
        imageBase = 'nui://ox_inventory/web/images/',
    }
end

local function showOwnedMenu()
    if menuOpen then return end

    local context = lib.callback.await('armasvip:getMyGrants', false)
    if not context or context.identityError then
        lib.notify({
            title = 'Armas VIP',
            description = 'No se pudo identificar tu personaje.',
            type = 'error',
        })
        return
    end

    local grants = context.grants or {}
    if #grants == 0 then
        lib.notify({
            title = 'Armas VIP',
            description = 'No tienes armas VIP asignadas.',
            type = 'inform',
        })
        return
    end

    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openOwned', data = ownedPayload(context) })
end

local function showGrantManager()
    local grants = lib.callback.await('armasvip:getAdminGrants', false)
    if grants == nil then
        lib.notify({ title = 'Armas VIP', description = 'No tienes permiso.', type = 'error' })
        return
    end

    local options = {}
    for _, grant in ipairs(grants) do
        local current = grant
        options[#options + 1] = {
            title = ('%s · %s'):format(current.ownerName or 'Jugador', current.label),
            description = expiryLabel(current.expiresAt),
            icon = 'gun',
            iconColor = '#ff7a00',
            metadata = {
                { label = 'Accesorios iniciales', value = componentSummary(current.components) },
                { label = 'Camo activo', value = locale('tint_' .. tostring(current.tint or 0)) },
                { label = 'Camos desbloqueados', value = #(current.unlockedTints or {}) },
                { label = 'Grant ID', value = current.id },
            },
            onSelect = function()
                local actionId = ('armasvip_grant_actions_%s'):format(current.id)
                lib.registerContext({
                    id = actionId,
                    title = ('%s · %s'):format(current.ownerName or 'Jugador', current.label),
                    menu = 'armasvip_manage_grants',
                    options = {
                        {
                            title = 'Gestionar camos',
                            description = 'Desbloquear o retirar acabados/tintes permanentes.',
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
                                        description = isUnlocked and 'Desbloqueado' or 'Bloqueado',
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
                                                    title = 'Armas VIP',
                                                    description = isUnlocked and 'Camo retirado.' or 'Camo desbloqueado.',
                                                    type = 'success',
                                                })
                                                showGrantManager()
                                            else
                                                local reason = result and result.reason
                                                lib.notify({
                                                    title = 'Armas VIP',
                                                    description = reason == 'default_tint' and 'El acabado por defecto siempre debe estar disponible.' or 'No se pudo modificar el camo.',
                                                    type = 'error',
                                                })
                                            end
                                        end,
                                    }
                                end
                                local tintMenuId = ('armasvip_grant_tints_%s'):format(current.id)
                                lib.registerContext({ id = tintMenuId, title = 'Camos desbloqueados', menu = actionId, options = tintOptions })
                                lib.showContext(tintMenuId)
                            end,
                        },
                        {
                            title = 'Revocar arma VIP',
                            description = 'Elimina la propiedad permanente y retira la instancia si está conectado.',
                            icon = 'trash',
                            iconColor = '#ef4444',
                            onSelect = function()
                                local answer = lib.alertDialog({
                                    header = 'Revocar arma VIP',
                                    content = ('¿Revocar **%s** a **%s**?'):format(current.label, current.ownerName or 'Jugador'),
                                    centered = true,
                                    cancel = true,
                                })
                                if answer ~= 'confirm' then return end
                                local result = lib.callback.await('armasvip:revokeGrant', false, current.id)
                                if result and result.ok then
                                    lib.notify({ title = 'Armas VIP', description = 'Asignación revocada.', type = 'success' })
                                    showGrantManager()
                                else
                                    lib.notify({ title = 'Armas VIP', description = 'No se pudo revocar la asignación.', type = 'error' })
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
        options[1] = { title = 'Sin asignaciones activas', description = 'Todavía no hay armas VIP asignadas.', icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'armasvip_manage_grants', title = 'Gestionar Armas VIP', options = options })
    lib.showContext('armasvip_manage_grants')
end

local function assignSelectedWeapon(data)
    local context = lib.callback.await('armasvip:getAdminContext', false)
    if not context then
        lib.notify({ title = 'Armas VIP', description = 'No tienes permiso.', type = 'error' })
        return
    end

    local playerOptions = {}
    for _, player in ipairs(context.players or {}) do
        playerOptions[#playerOptions + 1] = {
            value = tostring(player.source),
            label = ('[%s] %s'):format(player.source, player.name),
        }
    end

    if #playerOptions == 0 then
        lib.notify({
            title = 'Armas VIP',
            description = 'No hay jugadores conectados para asignar.',
            type = 'error',
        })
        Wait(100)
        openAdminMenu()
        return
    end

    local durationOptions = {}
    for _, duration in ipairs(context.durations or {}) do
        durationOptions[#durationOptions + 1] = {
            value = tostring(duration.days),
            label = duration.label,
        }
    end

    local input = lib.inputDialog('Asignar arma VIP', {
        {
            type = 'select',
            label = 'Jugador',
            description = 'La propiedad queda vinculada a su identidad persistente.',
            options = playerOptions,
            searchable = true,
            required = true,
        },
        {
            type = 'select',
            label = 'Duración',
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
        local reasons = {
            invalid_identity = 'No se pudo identificar al jugador o al administrador.',
            target_offline = 'El jugador ya no está conectado.',
            database_not_ready = 'La base de datos todavía no está lista.',
            invalid_weapon = 'El arma seleccionada no es válida.',
        }

        lib.notify({
            title = 'Armas VIP',
            description = reasons[result and result.reason] or 'No se pudo crear la asignación VIP.',
            type = 'error',
        })
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

    CreateThread(function()
        assignSelectedWeapon(data)
    end)
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
