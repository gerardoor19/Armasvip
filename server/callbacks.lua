local weaponsByName = {}
for _, weapon in ipairs(ArmasVipData.weapons) do
    weaponsByName[weapon.name] = weapon
end

---@param weapon table
---@param requested unknown
---@return string[]
local function filterValidComponents(weapon, requested)
    return ArmasVipGrants.ResolveComponents(weapon, requested)
end

---@param requestedTint unknown
---@return integer
local function resolveValidTint(requestedTint)
    return ArmasVipGrants.ResolveTint(requestedTint)
end

-- Callback legacy: se conserva para no romper integraciones externas existentes.
lib.callback.register('armasvip:giveWeapon', function(source, payload)
    if not isAllowed(source) then
        notify(source, locale('no_permission'), 'error')
        return false
    end

    if type(payload) ~= 'table' or type(payload.weapon) ~= 'string' then return false end

    local weapon = weaponsByName[payload.weapon:upper()]
    if not weapon then
        notify(source, locale('invalid_weapon'), 'error')
        return false
    end

    local validComponents = filterValidComponents(weapon, payload.components)
    local validTint = resolveValidTint(payload.tint)
    local metadata = { components = validComponents }

    if not weapon.throwable then metadata.ammo = Config.ChamberAmmo end
    if validTint and validTint > 0 then metadata.tint = validTint end

    local success, response = exports.ox_inventory:AddItem(source, weapon.name, 1, metadata)
    if not success then
        notify(source, locale('give_failed', response or locale('give_failed_reason_full')), 'error')
        return false
    end

    if weapon.ammoname and not weapon.throwable then
        exports.ox_inventory:AddItem(source, weapon.ammoname, Config.ReserveAmmo)
    end

    notify(source, locale('given', weapon.label, #validComponents), 'success')
    return true
end)

lib.callback.register('armasvip:getAdminContext', function(source)
    if not isAllowed(source) then return nil end

    return {
        players = ArmasVipIdentity.OnlinePlayers(),
        durations = Config.Grants.DurationOptions,
        identityProvider = ArmasVipIdentity.Provider(),
    }
end)

lib.callback.register('armasvip:getAdminGrants', function(source)
    if not isAllowed(source) then return nil end
    return ArmasVipGrants.GetAll()
end)

lib.callback.register('armasvip:createGrant', function(source, payload)
    if not isAllowed(source) then return { ok = false, reason = 'no_permission' } end
    if type(payload) ~= 'table' then return { ok = false, reason = 'invalid_payload' } end

    local target = tonumber(payload.targetSource)
    if not target or not GetPlayerName(target) then
        return { ok = false, reason = 'target_offline' }
    end

    local ok, result = ArmasVipGrants.Create(source, target, payload)
    if not ok then return { ok = false, reason = result } end

    local delivered, deliveryResult = ArmasVipGrants.Equip(target, result.id)

    if delivered then
        notify(source, ('Arma VIP asignada y entregada a %s.'):format(result.ownerName or GetPlayerName(target)), 'success')
        notify(target, ('%s ahora es tu arma VIP y ya fue añadida a tu inventario.'):format(result.label), 'success')
    else
        local deliveryMessages = {
            inventory_full = 'No tiene espacio en el inventario.',
            already_equipped = 'Ya existe una instancia de esta asignación en su inventario.',
            invalid_identity = 'No se pudo identificar al jugador.',
            invalid_weapon = 'La asignación contiene un arma inválida.',
            database_not_ready = 'El sistema VIP todavía está iniciando.',
            grant_busy = 'La asignación está siendo procesada.',
            grant_not_found = 'No se pudo revalidar la asignación recién creada.',
        }
        local detail = deliveryMessages[deliveryResult] or ('Entrega física fallida: %s'):format(tostring(deliveryResult))

        notify(source, ('La propiedad VIP fue guardada para %s, pero no se pudo entregar ahora: %s'):format(
            result.ownerName or GetPlayerName(target),
            detail
        ), 'warning')
        notify(target, ('%s ya es tu arma VIP. No pudo añadirse ahora (%s). Usa /%s para recuperarla.'):format(
            result.label,
            detail,
            Config.PlayerCommand
        ), 'warning')
    end

    return {
        ok = true,
        grant = result,
        delivered = delivered == true,
        deliveryReason = delivered and nil or deliveryResult,
    }
end)

lib.callback.register('armasvip:revokeGrant', function(source, id)
    if not isAllowed(source) then return { ok = false, reason = 'no_permission' } end

    local grant = ArmasVipGrants.Get(id)
    if not grant then return { ok = false, reason = 'grant_not_found' } end

    local target = ArmasVipIdentity.FindOnlineByKey(grant.owner_key)
    local weapon = ArmasVipGrants.GetWeapon(grant.weapon)
    local label = weapon and weapon.label or grant.weapon

    local ok, reason = ArmasVipGrants.Revoke(source, id)
    if not ok then return { ok = false, reason = reason } end

    if target then
        notify(target, ('Tu acceso VIP a %s fue revocado.'):format(label), 'error')
    end

    return { ok = true }
end)

lib.callback.register('armasvip:getMyGrants', function(source)
    ArmasVipGrants.CleanupInventory(source)

    local identity = ArmasVipIdentity.Get(source)
    if not identity then return { grants = {}, identityError = true } end

    local context, reason = ArmasVipGrants.GetOwnerState(source)
    if not context then return { grants = {}, identityError = reason == 'invalid_identity' } end
    return context
end)

lib.callback.register('armasvip:equipGrant', function(source, grantId)
    local ok, result = ArmasVipGrants.Equip(source, grantId)
    if not ok then
        local messages = {
            grant_not_found = 'Esta asignación no existe, expiró o no te pertenece.',
            already_equipped = 'Ya tienes esta arma VIP en tu inventario.',
            inventory_full = 'No tienes espacio suficiente en el inventario.',
            invalid_identity = 'No se pudo identificar tu personaje.',
            database_not_ready = 'El sistema VIP aún está iniciando.',
            invalid_weapon = 'La asignación contiene un arma inválida.',
            grant_busy = 'Esta arma VIP ya se está procesando. Inténtalo de nuevo.',
        }

        notify(source, messages[result] or 'No se pudo equipar el arma VIP.', 'error')
        return { ok = false, reason = result }
    end

    notify(source, ('%s equipada.'):format(result.label), 'success')
    return { ok = true, grant = result }
end)

RegisterNetEvent('armasvip:server:repairVipDurability', function(slot, grantId)
    ArmasVipGrants.RepairVipSlot(source, slot, grantId)
end)

RegisterNetEvent('armasvip:server:cleanup', function()
    ArmasVipGrants.CleanupInventory(source)
end)

lib.callback.register('armasvip:setActiveTint', function(source, payload)
    if type(payload) ~= 'table' then return { ok = false, reason = 'invalid_payload' } end
    local ok, result = ArmasVipGrants.SetActiveTint(source, payload.grantId, payload.tint)
    if not ok then
        local messages = {
            grant_not_found = 'Esta arma VIP no te pertenece o ya no está activa.',
            tint_locked = 'Ese camo no está desbloqueado para esta arma.',
            invalid_identity = 'No se pudo identificar tu personaje.',
        }
        notify(source, messages[result] or 'No se pudo cambiar el camo.', 'error')
        return { ok = false, reason = result }
    end
    notify(source, 'Camo aplicado y guardado.', 'success')
    return { ok = true, grant = result }
end)

lib.callback.register('armasvip:setTintUnlock', function(source, payload)
    if not isAllowed(source) then return { ok = false, reason = 'no_permission' } end
    if type(payload) ~= 'table' then return { ok = false, reason = 'invalid_payload' } end
    local ok, result = ArmasVipGrants.SetTintUnlocked(source, payload.grantId, payload.tint, payload.unlocked == true)
    return { ok = ok, reason = ok and nil or result, grant = ok and result or nil }
end)
