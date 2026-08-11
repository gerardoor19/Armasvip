ArmasVipIdentity = ArmasVipIdentity or {}

local detectedProvider
local qbCore
local esx

local function started(resource)
    return GetResourceState(resource) == 'started'
end

local function provider()
    local configured = tostring(Config.Identity and Config.Identity.Provider or 'auto'):lower()
    if configured ~= 'auto' then
        if detectedProvider ~= configured then
            detectedProvider = configured
            print(('[armasvip] Identity provider: %s'):format(detectedProvider))
        end
        return detectedProvider
    end

    local current
    if started('qbx_core') then current = 'qbox'
    elseif started('qb-core') then current = 'qbcore'
    elseif started('es_extended') then current = 'esx'
    else current = 'license' end

    if detectedProvider ~= current then
        detectedProvider = current
        print(('[armasvip] Identity provider: %s'):format(detectedProvider))
    end
    return detectedProvider
end

local function qboxIdentity(source)
    local ok, player = pcall(function()
        return exports.qbx_core:GetPlayer(source)
    end)
    if not ok or not player or not player.PlayerData then return nil end

    local data = player.PlayerData
    if not data.citizenid then return nil end
    local charinfo = data.charinfo or {}
    local name = (('%s %s'):format(charinfo.firstname or '', charinfo.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then name = data.name or GetPlayerName(source) or tostring(source) end

    return {
        provider = 'qbox',
        id = tostring(data.citizenid),
        key = ('qbox:%s'):format(data.citizenid),
        name = name,
    }
end

local function qbcoreIdentity(source)
    if not qbCore then
        local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
        if not ok or not core then return nil end
        qbCore = core
    end

    local player = qbCore.Functions.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.citizenid then return nil end
    local data = player.PlayerData
    local charinfo = data.charinfo or {}
    local name = (('%s %s'):format(charinfo.firstname or '', charinfo.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then name = data.name or GetPlayerName(source) or tostring(source) end

    return {
        provider = 'qbcore',
        id = tostring(data.citizenid),
        key = ('qbcore:%s'):format(data.citizenid),
        name = name,
    }
end

local function esxIdentity(source)
    if not esx then
        local ok, object = pcall(function() return exports['es_extended']:getSharedObject() end)
        if not ok or not object then return nil end
        esx = object
    end

    local player = esx.GetPlayerFromId(source)
    if not player then return nil end
    local identifier = player.identifier or (player.getIdentifier and player.getIdentifier())
    if not identifier then return nil end
    local name = (player.getName and player.getName()) or GetPlayerName(source) or tostring(source)

    return {
        provider = 'esx',
        id = tostring(identifier),
        key = ('esx:%s'):format(identifier),
        name = name,
    }
end

local function licenseIdentity(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')
    if not identifier then
        local identifiers = GetPlayerIdentifiers(source)
        identifier = identifiers and identifiers[1]
    end
    if not identifier then return nil end

    return {
        provider = 'license',
        id = tostring(identifier),
        key = ('license:%s'):format(identifier),
        name = GetPlayerName(source) or tostring(source),
    }
end

function ArmasVipIdentity.Get(source)
    source = tonumber(source)
    if not source or source <= 0 then return nil end

    local selected = provider()
    local identity
    if selected == 'qbox' then identity = qboxIdentity(source)
    elseif selected == 'qbcore' then identity = qbcoreIdentity(source)
    elseif selected == 'esx' then identity = esxIdentity(source)
    elseif selected == 'license' then identity = licenseIdentity(source)
    end

    return identity
end

function ArmasVipIdentity.Provider()
    return provider()
end

function ArmasVipIdentity.OnlinePlayers()
    local result = {}
    for _, value in ipairs(GetPlayers()) do
        local source = tonumber(value)
        local identity = source and ArmasVipIdentity.Get(source)
        if identity then
            result[#result + 1] = {
                source = source,
                name = identity.name,
                ownerKey = identity.key,
            }
        end
    end

    table.sort(result, function(a, b)
        return tostring(a.name):lower() < tostring(b.name):lower()
    end)
    return result
end

function ArmasVipIdentity.FindOnlineByKey(ownerKey)
    for _, value in ipairs(GetPlayers()) do
        local source = tonumber(value)
        local identity = source and ArmasVipIdentity.Get(source)
        if identity and identity.key == ownerKey then return source end
    end
    return nil
end
