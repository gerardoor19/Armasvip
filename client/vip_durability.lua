-- Mantiene sin desgaste únicamente la instancia VIP actualmente equipada.
-- No escanea inventarios ni modifica ox_inventory: reacciona a la sincronización
-- oficial `ox_inventory:currentWeapon` y delega la validación final al servidor.

local lastRepair = {}

local function isVipWeapon(weapon)
    local metadata = type(weapon) == 'table' and weapon.metadata or nil
    return type(metadata) == 'table'
        and metadata.armasvip == true
        and tonumber(metadata.vipGrantId) ~= nil
        and type(metadata.vipOwner) == 'string'
        and metadata.vipOwner ~= ''
end

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    if Config.Grants.InfiniteDurability == false then return end
    if not isVipWeapon(weapon) then return end

    local durability = tonumber(weapon.metadata.durability)
    local target = math.max(1, math.min(100, tonumber(Config.Grants.Durability) or 100))
    if durability and durability >= target then return end

    local slot = tonumber(weapon.slot)
    local grantId = tonumber(weapon.metadata.vipGrantId)
    if not slot or not grantId then return end

    -- Evita duplicar solicitudes si otro recurso provoca varias sincronizaciones
    -- del mismo slot en el mismo instante. No es un loop ni un escaneo periódico.
    local now = GetGameTimer()
    if lastRepair[grantId] and now - lastRepair[grantId] < 500 then return end
    lastRepair[grantId] = now

    TriggerServerEvent('armasvip:server:repairVipDurability', slot, grantId)
end)

RegisterNetEvent('armasvip:client:applyVipTint', function(grantId, weaponName, tint)
    local current = exports.ox_inventory:getCurrentWeapon()
    if not isVipWeapon(current) then return end
    if tonumber(current.metadata.vipGrantId) ~= tonumber(grantId) then return end
    if tostring(current.name):upper() ~= tostring(weaponName):upper() then return end

    local hash = joaat(current.name)
    if GetSelectedPedWeapon(PlayerPedId()) ~= hash then return end
    SetPedWeaponTintIndex(PlayerPedId(), hash, tonumber(tint) or 0)
end)
