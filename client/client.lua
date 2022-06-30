QBCore = exports['qb-core']:GetCoreObject()

local showtext = false

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for type, v in pairs(Config.ATM) do
            local entity = GetClosestObjectOfType(pedCoords.x ,pedCoords.y, pedCoords.z, 1.0, GetHashKey(v), 0, 0, 0)
            if entity ~= nil then
                local entitypos = GetEntityCoords(entity)
                local entityheading = GetEntityHeading(entity)
                local dist = #(pedCoords - entitypos)
                if dist < 10 then
                    if dist <= 1.8 then
                        sleep = 0
                        if not showtext then
                            Draw3DText(entitypos, "~r~[E]~w~ To Start Robbery")
                        end
                        if IsControlJustPressed(0, 51) then
                            QBCore.Functions.TriggerCallback('atm:cooldown', function(cooldown)
                                if not cooldown then
                                    SetEntityCoordsNoOffset(ped, pedCoords)
                                    SetEntityHeading(ped, entityheading)
                                    QBCore.Functions.Progressbar('name_here', 'Hacking Into ATM...', 15000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {
                                        animDict = 'amb@world_human_stand_mobile@male@text@idle_a',
                                        anim = 'idle_a',
                                        flags = 1,
                                    }, {}, {}, function() --Done
                                        TriggerServerEvent('atm:client:sketchy') -- Anti Cheat (if the cheater is smart enough then he would be able to bypass it)
                                        TriggerServerEvent('atm:server:startrob')
                                        TriggerServerEvent('atm:server:begincooldown')
                                    end, function() -- Cancel
                                        showtext = false
                                        QBCore.Functions.Notify('Hacking Canceled!', 'success')
                                        StopAnimTask(ped, "amb@world_human_stand_mobile@male@text@idle_a", "idle_a", 1.0)
                                    end)
                                else
                                    QBCore.Functions.TriggerCallback('atm:time', function(time)
                                        QBCore.Functions.Notify('Please Wait '.. time .. ' seconds!', 'error')
                                    end)
                                end
                            end)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function Draw3DText(coords, str)
    local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z+1)
	local camCoords = GetGameplayCamCoord()
	local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
    if onScreen then
        SetTextScale(1.0, 0.5 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextEdge(2, 0, 0, 0, 150)
		SetTextProportional(1)
		SetTextOutline()
		SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(str)
        EndTextCommandDisplayText(worldX, worldY)
    end
end

RegisterNetEvent('atm:client:startrob')
AddEventHandler('atm:client:startrob', function()
    showtext = true
    exports["datacrack"]:Start(2)
end)

AddEventHandler("datacrack", function(output)
    if output then
        showtext = false
        QBCore.Functions.Notify('Hack Completed!', 'success')
        StopAnimTask(PlayerPedId(), "amb@world_human_stand_mobile@male@text@idle_a", "idle_a", 1.0)
        GrabCash()
        TriggerServerEvent('atm:server:getcash')
    else
        showtext = false
        QBCore.Functions.Notify('Hack Failed!', 'error')
    end
end)

function hintToDisplay(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, 20000)
end

function GrabCash()
    RequestAnimDict('anim@heists@ornate_bank@grab_cash_heels')
    while not HasAnimDictLoaded('anim@heists@ornate_bank@grab_cash_heels') do
        Wait(50)
    end
    local ped = PlayerPedId()
    local PedCoords = GetEntityCoords(PlayerPedId())
    local bag = CreateObject(`hei_p_m_bag_var22_arm_s`, GetEntityCoords(ped), true)
    local MoneyObject = CreateObject(`hei_prop_heist_cash_pile`, GetEntityCoords(ped), true)
    SetEntityVisible(MoneyObject, true, true)
    AttachEntityToEntity(MoneyObject, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
    AttachEntityToEntity(bag, ped, GetPedBoneIndex(ped, 57005), 0.0, 0.0, -0.16, 250.0, -30.0, 0.0, false, false, false, false, 2, true)
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 8.0, -8.0, -1, 1, 0, false, false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    QBCore.Functions.Notify('You are packing cash into a bag', "success")
    local _time = GetGameTimer()
    while GetGameTimer() - _time < 20000 do
        if IsControlPressed(0, 47) then
            DeleteEntity(bag)
            break
        end
        hintToDisplay("Press ~INPUT_DETONATE~ \nTo Cum Hard")
        Wait(1)
    end
    SetEntityVisible(MoneyObject, false, false)
    DeleteObject(MoneyObject)
    ClearPedTasks(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    SetPedComponentVariation(PlayerPedId(), 5, 45, 0, 2)
    Wait(2500)
end

PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)