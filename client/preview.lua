-- Unified arsenal preview callbacks.
-- The NUI always previews the skin inside the weapon silhouette. When the same
-- VIP grant is currently equipped, the runtime texture is also applied locally
-- as a temporary preview and restored from persisted state on cancel/close.

local function restorePersistedSkin()
    if GetResourceState('ox_inventory') ~= 'started' then return end
    local weapon = exports.ox_inventory:getCurrentWeapon()
    TriggerEvent('ox_inventory:currentWeapon', weapon)
end

RegisterNUICallback('armasvip:previewSkin', function(data, cb)
    data = type(data) == 'table' and data or {}
    local grantId = tonumber(data.grantId)
    local weaponName = type(data.weapon) == 'string' and data.weapon or nil
    local skinId = type(data.skinId) == 'string' and data.skinId or nil

    if grantId and weaponName and skinId and ArmasVipSkins.Get(skinId) then
        TriggerEvent('armasvip:client:applyVipSkin', grantId, weaponName, skinId)
    end

    cb(true)
end)

RegisterNUICallback('armasvip:cancelSkinPreview', function(_, cb)
    restorePersistedSkin()
    cb(true)
end)

RegisterNetEvent('armasvip:client:restorePersistedSkin', restorePersistedSkin)
