local function vipMetadata(slot)
    if type(slot) ~= 'table' or type(slot.metadata) ~= 'table' then return nil end
    return ArmasVipGrants.IsVipWeapon(slot.metadata) and slot.metadata or nil
end

local function inventoryId(inventory)
    if type(inventory) == 'number' or type(inventory) == 'string' then return tostring(inventory) end
    if type(inventory) ~= 'table' then return nil end
    return tostring(inventory.id or inventory.source or inventory.owner or '')
end

CreateThread(function()
    if Config.Grants.ProtectTransfers == false then return end

    local deadline = GetGameTimer() + 30000
    while GetResourceState('ox_inventory') ~= 'started' and GetGameTimer() < deadline do
        Wait(250)
    end

    if GetResourceState('ox_inventory') ~= 'started' then
        print('^1[armasvip] ERROR: ox_inventory no está iniciado; protección de transferencias VIP no registrada.^0')
        return
    end

    local ok, err = pcall(function()
        exports.ox_inventory:registerHook('swapItems', function(payload)
            if type(payload) ~= 'table' then return end

            local movingVip = vipMetadata(payload.fromSlot)
            local targetVip = vipMetadata(payload.toSlot)
            if not movingVip and not targetVip then return end

            local fromId = inventoryId(payload.fromInventory)
            local toId = inventoryId(payload.toInventory)
            local sameInventory = fromId ~= nil and toId ~= nil and fromId ~= '' and fromId == toId

            if sameInventory and payload.action ~= 'give' then return end
            return false
        end)
    end)

    if not ok then
        print(('^1[armasvip] ERROR registrando hook swapItems: %s^0'):format(tostring(err)))
        print('^3[armasvip] Revisa la versión de ox_inventory. El resto del recurso seguirá cargado.^0')
    end
end)
