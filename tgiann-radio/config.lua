Config = {}

Config.framework = false -- false - "esx" - "qb"
Config.voipScript = "salty" -- "salty" - "mumble" - "pma" - "toko"
Config.useItem = false -- (Need ESX or qb)
Config.ItemName = "radio" -- database item name
Config.RaidoKey = "f9" -- If you change the key, you need to delete the fivem cache. https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
Config.LeaveRadioDie = false -- leave the radio when you die
Config.LeaveRadioDrop = false -- leave the radio channel when you drop the item on the ground(Need ESX) (not working in qb)
Config.restrictChannel = { -- (Jobs Need ESX or qb)
    {channel = 1, acePerms = {"group.police"}},
    {channel = 2, jobs = {"police"}, acePerms = {"group.ambulance"}},
    {channel = 3, jobs = {"police", "ambulance"}, acePerms = {"group.police", "group.ambulance"}},
    {channel = 4, jobs = {"ambulance"}},
    {channel = 5, jobs = {"ambulance", "police"}},
}

--[[ 
    example ace permission (https://forum.cfx.re/t/basic-aces-principals-overview-guide/90917)
    add_ace group.jobs group.police allow
    add_ace group.jobs group.ambulance allow
    add_principal identifier.steam:xxxxxxxxx group.jobs
]]

-- Mumble Voip Setting
Config.ActivatorKey = 137 -- Capslock

-- Tokovoip Setting
Config.scriptName = "tokovoip_script" -- "tokovoip" - "toko-voip" - "tokovoip-script" - "tokovoip_script"