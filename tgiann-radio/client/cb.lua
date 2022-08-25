local CurrentRequestId = 0
local ServerCallbacks = {}

RegisterNetEvent('Tgiann:Client:TriggerCallback')
AddEventHandler('Tgiann:Client:TriggerCallback', function(requestId, ...)
	if ServerCallbacks[requestId] then
		ServerCallbacks[requestId](...)
		ServerCallbacks[requestId] = nil
	end
end)

function TriggerCallback(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb
	TriggerServerEvent("Tgiann:Server:TriggerCallback", name, CurrentRequestId, ...)
	if CurrentRequestId < 65535 then CurrentRequestId = CurrentRequestId + 1 else CurrentRequestId = 0 end
end

RegisterNetEvent("tgiann:client:notif")
AddEventHandler("tgiann:client:notif", function(text)
	showNotification(text)
end)