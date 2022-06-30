QBCore = exports['qb-core']:GetCoreObject()

local PoliceAmount = 0
local MissionStarted = false
local cooldown = false
local nigger = {}
local robtime = 0

function GetCops()
    local Players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(Players) do
        if v.PlayerData.job.name == 'police' and v.PlayerData.job.onduty then
            PoliceAmount = PoliceAmount + 1
        end
    end
end

RegisterNetEvent('atm:server:startrob', function()
    local src = source
    GetCops()
    if not MissionStarted then
        if PoliceAmount ~= 0 and PoliceAmount >= Config.RequiredCops then
            MissionStarted = true
            TriggerClientEvent('atm:client:startrob', src)
            robtime = os.time()
            SetTimeout(Config.Cooldown * 1000, function()
                MissionStarted = false
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Not enough online cops!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Please Wait '.. (Config.Cooldown - (os.time() - robtime)) .. ' seconds!', 'error')
    end
end)

RegisterNetEvent('atm:server:getcash')
AddEventHandler('atm:server:getcash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cash = math.random(Config.Money.Min, Config.Money.Max)

    if MissionStarted then
        if nigger then
            if Config.BlackMoney then
                local info = {
                    worth = cash
                }
                Player.Functions.AddItem('markedbills', 1, false, info)
                TriggerClientEvent('QBCore:Notify', src, "You've received worth $".. info.worth .. " of marked money!", 'success')
            else
                Player.Functions.AddMoney("cash", cash)
            end
        else
            print('Attempted To TriggerServerEvent : nigger'.. Player.PlayerData.source)
        end
    else
        print('Attempted To TriggerServerEvent : MissionStarted'.. Player.PlayerData.source)
    end
end)

RegisterNetEvent('atm:server:sketchy')
AddEventHandler('atm:server:sketchy', function()
    local src = source
    if nigger[src] == nil or nigger[src] == false then 
        nigger[src] = true
    end
end)

RegisterNetEvent('atm:server:begincooldown')
AddEventHandler('atm:server:begincooldown', function()
    cooldown = true
    while (Config.Cooldown - (os.time() - robtime)) > 0 do
        Wait(1000)
        if (Config.Cooldown - (os.time() - robtime)) <= 0 then
            cooldown = false
        end
    end
end)

QBCore.Functions.CreateCallback("atm:cooldown",function(source, cb)
    if cooldown then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback("atm:time",function(source, cb)
    cb((Config.Cooldown - (os.time() - robtime)))
end)