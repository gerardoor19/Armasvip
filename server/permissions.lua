-- Compartido entre server/commands.lua y server/callbacks.lua.
-- Sin 'local' a proposito: los server_scripts de un mismo resource comparten
-- un unico entorno global.

---@param source integer
---@return boolean
function isAllowed(source)
	return source == 0 or IsPlayerAceAllowed(source, Config.Ace)
end

---@param source integer
---@param description string
---@param notifyType? string
function notify(source, description, notifyType)
	TriggerClientEvent('ox_lib:notify', source, {
		title = locale('notify_title'),
		description = description,
		type = notifyType or 'inform',
	})
end
