local currentWeapon = nil
local inspecting = false

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    currentWeapon = weapon
    if inspecting and (not weapon or type(weapon.metadata) ~= 'table' or weapon.metadata.armasvip ~= true) then
        inspecting = false
        ClearPedSecondaryTask(PlayerPedId())
    end
end)

local function isVipWeaponEquipped()
    return currentWeapon
        and type(currentWeapon.metadata) == 'table'
        and currentWeapon.metadata.armasvip == true
        and tonumber(currentWeapon.metadata.vipGrantId) ~= nil
end

local function requestAnim(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do Wait(0) end
    return HasAnimDictLoaded(dict)
end

local function inspectWeapon()
    local settings = Config.Skins and Config.Skins.Inspect or nil
    if not settings or settings.Enabled == false or inspecting or not isVipWeaponEquipped() then return end

    local ped = PlayerPedId()
    if IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) then return end

    local dict = tostring(settings.Dict or 'shared@fidgets')
    local clip = tostring(settings.Clip or 'fidget_med_loop')
    if not requestAnim(dict) then return end

    inspecting = true
    local duration = math.max(500, tonumber(settings.Duration) or 2600)
    TaskPlayAnim(ped, dict, clip, 3.0, -3.0, duration, tonumber(settings.Flag) or 49, 0.0, false, false, false)

    CreateThread(function()
        local deadline = GetGameTimer() + duration
        while inspecting and GetGameTimer() < deadline do
            Wait(0)
            if IsPedShooting(ped)
                or IsControlPressed(0, 24)
                or IsControlPressed(0, 25)
                or not isVipWeaponEquipped() then
                break
            end
        end

        if inspecting then ClearPedSecondaryTask(ped) end
        inspecting = false
    end)
end

local command = (Config.Skins and Config.Skins.Inspect and Config.Skins.Inspect.Command) or 'vipinspect'
RegisterCommand(command, inspectWeapon, false)

local defaultKey = Config.Skins and Config.Skins.Inspect and Config.Skins.Inspect.Key
if defaultKey and defaultKey ~= '' then
    RegisterKeyMapping(command, locale('inspect_keybind_description'), 'keyboard', defaultKey)
end
