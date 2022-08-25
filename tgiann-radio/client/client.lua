local PlayerData = {}
local myFramework = nil

if Config.framework == "esx" then
	Citizen.CreateThread(function()
		while myFramework == nil do
			TriggerEvent('esx:getSharedObject', function(obj) myFramework = obj end)
			Citizen.Wait(0)
		end
		while myFramework.GetPlayerData().job == nil do Citizen.Wait(100) end
		PlayerData = myFramework.GetPlayerData()
	end)

	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function()
		PlayerData = myFramework.GetPlayerData()
	end)

	RegisterNetEvent('esx:setJob')
	AddEventHandler('esx:setJob', function(job)
		PlayerData.job = job
	end)
elseif Config.framework == "qb" then
    Citizen.CreateThread(function()
		myFramework = exports['qb-core']:GetCoreObject()
		while myFramework.Functions.GetPlayerData().job == nil do Citizen.Wait(100) end
		PlayerData = myFramework.Functions.GetPlayerData()
	end)

	RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = myFramework.Functions.GetPlayerData()
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate')
    AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
        PlayerData.job = job
    end)
end

local radioProp = nil
local radioMenu = false
local raidoOn = false

if Config.LeaveRadioDie then
	RegisterNetEvent('baseevents:onPlayerDied')
	AddEventHandler('baseevents:onPlayerDied', function()
		radioLeave(true)
	end)
end

RegisterNetEvent('tgiann-radio:use')
AddEventHandler('tgiann-radio:use', function()
  	enableRadio(true)
end)

RegisterNetEvent('tgiann-radio:onRadioDrop')
AddEventHandler('tgiann-radio:onRadioDrop', function()
	radioLeave(true)
end)

RegisterNetEvent("tgiann-radio:t")
AddEventHandler("tgiann-radio:t", function(args)
	joinRadioChannel(false, tgiannRound(tonumber(args)))
end)

RegisterNetEvent("tgiann-radio:tk")
AddEventHandler("tgiann-radio:tk", function()
	radioLeave(false)
end)

RegisterNUICallback('joinRadio', function(data)
	joinRadioChannel(true, tonumber(data.channel))
end)

function joinRadioChannel(walkie, channelData)
	local channel = channelData
	if Config.voipScript == "salty" then
	 	playerInRadioChannel = exports["saltychat"]:GetRadioChannel()
	elseif Config.voipScript == "mumble" then
		playerInRadioChannel = exports["mumble-voip"]:GetPlayerRadioChannel(GetPlayerServerId(PlayerId()))
	end
	local haveItem = false
	if walkie or not Config.useItem then
		haveItem = true
	else
		if channelData == nil then
			showNotification("Frequency is insufficient")
			return
		elseif channelData < 1 then
			showNotification("You can't connect to this frequency")
			return
		end

		local waitSync = true
		TriggerCallback('tgiann:item-control', function(qtty)
			if qtty > 0 then
				haveItem = true
			end
			waitSync = false
		end, Config.ItemName)
		while waitSync do
			Citizen.Wait(100)
		end
	end

	if haveItem then
		if tonumber(playerInRadioChannel) == channel and not Config.voipScript == "pma" and not Config.voipScript == "toko" then
			showNotification("You are already on this frequency")
		else
			setPlayerRadioChannel(channel, walkie)
		end
	else
		showNotification("You don't have a radio")
	end
end

function setPlayerRadioChannel(channel, walkie)
	if Config.framework then
		local job = true


		for i=1, #Config.restrictChannel do
			if Config.restrictChannel[i].channel == tonumber(channel) then
				job = false
				if PlayerData.job then
					if Config.restrictChannel[i].jobs then
						for x=1, #Config.restrictChannel[i].jobs do
							if PlayerData.job.name == Config.restrictChannel[i].jobs[x] then
								job = true
								break
							end
						end
					end
					if not job then
						if Config.restrictChannel[i].acePerms then
							local acePerm = nil
							TriggerCallback('tgiann:acePerm-control', function(data)
								acePerm = data
								job = acePerm
							end, Config.restrictChannel[i].acePerms)
							while acePerm == nil do
								Citizen.Wait(100)
							end
						end
					end
				end
				break
			end
		end

		if job then
			if not walkie then tAnim() end
			if Config.voipScript == "salty" then
				TriggerServerEvent("tgiann-radio:set-channel", channel, false)
			elseif Config.voipScript == "mumble" then
				raidoOn = true
				exports["mumble-voip"]:SetMumbleProperty("radioEnabled", true)
				exports["mumble-voip"]:SetRadioChannel(tostring(channel), false)
			elseif Config.voipScript == "pma" then
				radioVolume = 100
				exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
				exports["pma-voice"]:setVoiceProperty("micClicks", true)
				exports["pma-voice"]:setRadioChannel(tonumber(channel))
				exports["pma-voice"]:setRadioVolume(1.0)
			elseif Config.voipScript == "toko" then
				radioVolume = 100
				exports[Config.scriptName]:addPlayerToRadio(channel, true)
				exports[Config.scriptName]:setRadioVolume(radioVolume)
			end
			enableRadio(false)
			SetNuiFocus(false, false)
			showNotification("You connected to frequency "..channel..".00 MHz")
		else
			showNotification("You cannot connect to this channel")
		end
	else
		local job = true
		for i=1, #Config.restrictChannel do
			if Config.restrictChannel[i].channel == tonumber(channel) then
				job = false
				if Config.restrictChannel[i].acePerms then
					local acePerm = nil
					TriggerCallback('tgiann:acePerm-control', function(data)
						acePerm = data
						job = acePerm
					end, Config.restrictChannel[i].acePerms)
					while acePerm == nil do
						Citizen.Wait(100)
					end
				end
				break
			end
		end
		if job then
			if not walkie then tAnim() end
			if Config.voipScript == "salty" then
				TriggerServerEvent("tgiann-radio:set-channel", channel, false)
			elseif Config.voipScript == "mumble" then
				raidoOn = true
				exports["mumble-voip"]:SetMumbleProperty("radioEnabled", true)
				exports["mumble-voip"]:SetRadioChannel(tostring(channel), false)
			elseif Config.voipScript == "pma" then
				radioVolume = 100
				exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
				exports["pma-voice"]:setVoiceProperty("micClicks", true)
				exports["pma-voice"]:setRadioChannel(tonumber(channel))
				exports["pma-voice"]:setRadioVolume(1.0)
			elseif Config.voipScript == "toko" then
				radioVolume = 100
				exports[Config.scriptName]:addPlayerToRadio(channel, true)
				exports[Config.scriptName]:setRadioVolume(radioVolume)
			end
			enableRadio(false)
			SetNuiFocus(false, false)
		else
			showNotification("You cannot connect to this channel")
		end
	end
end

RegisterNUICallback('leaveRadio', function(data)
	radioLeave(true)
end)

function radioLeave(walkie)
	local channel = channelData
	if Config.voipScript == "salty" then
		playerInRadioChannel = exports["saltychat"]:GetRadioChannel()
	elseif Config.voipScript == "mumble" then
		playerInRadioChannel = exports["mumble-voip"]:GetPlayerRadioChannel(GetPlayerServerId(PlayerId()))
	end
	local haveItem = false
	if walkie or not Config.useItem then
		haveItem = true
	else
		local waitSync = true
		TriggerCallback('tgiann-base:item-kontrol', function(qtty)
			if qtty > 0 then
				haveItem = true
			end
			waitSync = false
		end, Config.ItemName)
		while waitSync do
			Citizen.Wait(100)
		end
	end
	if haveItem then
		PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
		if not Config.voipScript == "pma" and not Config.voipScript == "toko" and (playerInRadioChannel == nil or tonumber(playerInRadioChannel) == 0) then
			showNotification('You are not already on a frequency!')
		else
			if Config.voipScript == "salty" then
				TriggerServerEvent("tgiann-radio:remove-channel", playerInRadioChannel)
			elseif Config.voipScript == "mumble" then
				raidoOn = false
				exports["mumble-voip"]:SetMumbleProperty("radioEnabled", false)
				exports["mumble-voip"]:SetRadioChannel(0)
			elseif Config.voipScript == "pma" then
				exports["pma-voice"]:setRadioChannel(0)
				exports["pma-voice"]:setVoiceProperty("micClicks", false)
				exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
			elseif Config.voipScript == "toko" then
				exports[Config.scriptName]:removePlayerFromRadio(channel)
			end
			showNotification("You left the frequency "..playerInRadioChannel.. ".00 MHz")
		end
	else
		showNotification("You don't have a radio")
	end
end

RegisterNUICallback('escape', function(data)
	enableRadio(false)
	SetNuiFocus(false, false)
end)

function enableRadio(enable)
	local ped = PlayerPedId()
	if enable then
		RequestAnimDictFunction("cellphone@", function() -- animasyon oynatma
			TaskPlayAnim(ped, "cellphone@", "cellphone_text_read_base", 3.0, 3.0, -1, 49, 0, false, false, false)
		end)
		if not HasModelLoaded("prop_cs_hand_radio") then loadPropDict("prop_cs_hand_radio") end
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, ped, GetPedBoneIndex(ped, 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
		SetModelAsNoLongerNeeded("prop_cs_hand_radio")
	else
		ClearPedTasks(ped)
		DeleteEntity(radioProp)
		radioProp = nil
	end

	SetNuiFocus(true, true)
	radioMenu = enable
	SendNUIMessage({type = "enableui",enable = enable})

	while radioMenu do
		if not radioMenu then break end
		DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
		DisableControlAction(0, 2, guiEnabled) -- LookUpDown
		DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
		DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
		Citizen.Wait(0)
	end
end

function tAnim()
	local ped = PlayerPedId()
	RequestAnimDictFunction("cellphone@", function()
		TaskPlayAnim(ped, "cellphone@", "cellphone_text_read_base", 3.0, 3.0, -1, 49, 0, false, false, false)
	end)

	if not HasModelLoaded("prop_cs_hand_radio") then
		loadPropDict("prop_cs_hand_radio")
	end
	radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
	AttachEntityToEntity(radioProp, ped, GetPedBoneIndex(ped, 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	SetModelAsNoLongerNeeded("prop_cs_hand_radio")
	Citizen.Wait(3000)
	ClearPedTasks(ped)
	DeleteEntity(radioProp)
	radioProp = nil
end

function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end

Citizen.CreateThread(function()
	RegisterKeyMapping('radio'..Config.RaidoKey, 'Radio', 'keyboard', Config.RaidoKey)
end)  

RegisterCommand('radio'..Config.RaidoKey, function()
	if radioProp == nil then
		if Config.useItem then
			TriggerCallback('tgiann:item-control', function(qtty)
				if qtty > 0 then
					enableRadio(true)
				else
					showNotification("You don't have a radio")
				end
			end, Config.ItemName)
		else
			enableRadio(true)
		end
	end
end, false)

local radioVolume = 100
RegisterNUICallback('sesac', function(data, cb)
	if Config.voipScript == "mumble" then
		showNotification("This feature does not work in mumble voip")
		return
	end
	PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	radioVolume = radioVolume + 5
	if radioVolume > 160 then radioVolume = 160 end
	if Config.voipScript == "salty" then
		exports["saltychat"]:SetRadioVolume(radioVolume/100)
	elseif Config.voipScript == "pma" then
		exports["pma-voice"]:setRadioVolume(radioVolume/100)
	elseif Config.voipScript == "toko" then
		exports[Config.scriptName]:setRadioVolume(radioVolume)
	end
	showNotification("Sound Level: "..radioVolume.."%")
end)

RegisterNUICallback('seskis', function(data, cb)
	if Config.voipScript == "mumble" then
		showNotification("This feature does not work in mumble voip")
		return
	end
	PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
	radioVolume = radioVolume - 5
	if radioVolume < 10 then radioVolume = 10 end
	if Config.voipScript == "salty" then
		exports["saltychat"]:SetRadioVolume(radioVolume/100)
	elseif Config.voipScript == "pma" then
		exports["pma-voice"]:setRadioVolume(radioVolume/100)
	elseif Config.voipScript == "toko" then
		exports[Config.scriptName]:setRadioVolume(radioVolume)
	end
	showNotification("Sound Level: "..radioVolume.."%")
end)

if Config.voipScript == "mumble" then
	local animDictionary = "random@arrests"
	local animationName = "generic_radio_chatter"

	local onAnim = false
	Citizen.CreateThread(function()
		while true do
			local time = 500
			if raidoOn then
				time = 1
				if IsControlJustPressed(0, Config.ActivatorKey) and not onAnim then
					onAnim = true
					local PlayerPed = PlayerPedId()
					if not IsEntityPlayingAnim(PlayerPed, animDictionary, animationName, 3) then
						RequestAnimDictFunction(animDictionary, function()
							TaskPlayAnim(PlayerPed, animDictionary, animationName, 4.0, -1, -1, 49, 0, false, false, false)
						end)
					end
				elseif IsControlJustReleased(0, Config.ActivatorKey) and onAnim then
					onAnim = false
					StopAnimTask(PlayerPedId(), animDictionary, animationName, -4.0)
				end
			end
			Citizen.Wait(time)
		end
	end)
end