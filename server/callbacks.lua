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
        notify(source, locale('grant_assigned_delivered', result.ownerName or GetPlayerName(target)), 'success')
        notify(target, locale('grant_received', result.label), 'success')
    else
        local deliveryKeys = {
            inventory_full = 'delivery_inventory_full',
            already_equipped = 'delivery_already_equipped',
            invalid_identity = 'delivery_invalid_identity',
            invalid_weapon = 'delivery_invalid_weapon',
            database_not_ready = 'delivery_database_not_ready',
            grant_busy = 'delivery_grant_busy',
            grant_not_found = 'delivery_grant_not_found',
        }
        local detail = deliveryKeys[deliveryResult] and locale(deliveryKeys[deliveryResult]) or locale('delivery_failed_reason', tostring(deliveryResult))

        notify(source, locale('grant_saved_delivery_failed', result.ownerName or GetPlayerName(target), detail), 'warning')
        notify(target, locale('grant_owned_delivery_failed', result.label, detail, Config.PlayerCommand), 'warning')
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
        notify(target, locale('grant_access_revoked', label), 'error')
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
        local messageKeys = {
            grant_not_found = 'equip_grant_not_found',
            already_equipped = 'equip_already_equipped',
            inventory_full = 'equip_inventory_full',
            invalid_identity = 'equip_invalid_identity',
            database_not_ready = 'equip_database_not_ready',
            invalid_weapon = 'equip_invalid_weapon',
            grant_busy = 'equip_grant_busy',
        }

        notify(source, messageKeys[result] and locale(messageKeys[result]) or locale('equip_failed'), 'error')
        return { ok = false, reason = result }
    end

    notify(source, locale('weapon_equipped', result.label), 'success')
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
        local messageKeys = {
            grant_not_found = 'tint_grant_not_found',
            tint_locked = 'tint_locked_for_weapon',
            invalid_identity = 'equip_invalid_identity',
        }
        notify(source, messageKeys[result] and locale(messageKeys[result]) or locale('tint_change_failed'), 'error')
        return { ok = false, reason = result }
    end
    notify(source, locale('tint_applied_saved'), 'success')
    return { ok = true, grant = result }
end)

lib.callback.register('armasvip:setTintUnlock', function(source, payload)
    if not isAllowed(source) then return { ok = false, reason = 'no_permission' } end
    if type(payload) ~= 'table' then return { ok = false, reason = 'invalid_payload' } end
    local ok, result = ArmasVipGrants.SetTintUnlocked(source, payload.grantId, payload.tint, payload.unlocked == true)
    return { ok = ok, reason = ok and nil or result, grant = ok and result or nil }
end)
