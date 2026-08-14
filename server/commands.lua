RegisterCommand(Config.Command, function(source)
    if source == 0 then
        print(locale('console_only', Config.Command))
        return
    end

    if not isAllowed(source) then
        notify(source, locale('no_permission'), 'error')
        return
    end

    TriggerClientEvent('armasvip:openAdmin', source)
end, false)

RegisterCommand(Config.PlayerCommand, function(source)
    if source == 0 then return end
    TriggerClientEvent('armasvip:openOwned', source)
end, false)

RegisterCommand(Config.ManageCommand, function(source)
    if source == 0 then return end

    if not isAllowed(source) then
        notify(source, locale('no_permission'), 'error')
        return
    end

    TriggerClientEvent('armasvip:manage', source)
end, false)

RegisterCommand(Config.SkinManageCommand, function(source)
    if source == 0 then return end

    if not isAllowed(source) then
        notify(source, locale('no_permission'), 'error')
        return
    end

    TriggerClientEvent('armasvip:manageSkins', source)
end, false)
