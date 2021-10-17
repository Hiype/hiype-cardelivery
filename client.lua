local isWorking = false
local vehicle = nil
local vehicleChoice = nil
local ped = nil
local cooldown = nil
local spawnLocation = nil
local destinationLocation = nil
local vehBlip = nil
local destinationBlip = nil
local npc = nil

local player = nil
local isLoggedIn = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("qb-clothes:loadPlayerSkin")
    isLoggedIn = true
    player = PlayerPedId()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        player = PlayerPedId()
        isLoggedIn = true
    end
end)

RegisterNetEvent("hiype-cardelivery:update-cooldown")
AddEventHandler("hiype-cardelivery:update-cooldown", function(status)
    cooldown = status
    print("Cooldown updated")
end)

-- Adds a blip
local blip = AddBlipForCoord(npcCoords.x, npcCoords.y, npcCoords.z)
SetBlipSprite(blip, 524)
SetBlipScale(blip, 0.8)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Car delivery job")
EndTextCommandSetBlipName(blip)

function carWithAi(aiEnabled)
    CreateThread(function()
        TriggerServerEvent("hiype_cardelivery:start_cooldown")
        vehicleChoice = math.random(1, #vehicles)
        local model = GetHashKey(vehicles[vehicleChoice].model)

        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        spawnLocation = math.random(1, #spawns)
        vehicle = CreateVehicle(model, spawns[spawnLocation].x, spawns[spawnLocation].y, spawns[spawnLocation].z, spawns[spawnLocation].heading, true, true)
        local netid = NetworkGetNetworkIdFromEntity(vehicle)

        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetNetworkIdCanMigrate(netid, true)
        SetVehicleNeedsToBeHotwired(vehicle, true)
        SetModelAsNoLongerNeeded(model)

        if notification then
            Citizen.Wait(1500)
            QBCore.Functions.Notify("Go get a " .. vehicles[vehicleChoice].name .. " at " .. spawns[spawnLocation].name .. "!", "success", 3500)

            -- -- Get the ped headshot image
            -- local handle = RegisterPedheadshot(npc)
            -- while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
            --     Citizen.Wait(0)
            -- end
            -- local txd = GetPedheadshotTxdString(handle)

            -- -- Add the notification text
            -- BeginTextCommandThefeedPost("STRING")
            -- AddTextComponentSubstringPlayerName("Go get a ~r~" .. vehicles[vehicleChoice].name .. "~w~ in ~g~" .. spawns[spawnLocation].name)
            
            -- -- Set the notification icon, title and subtitle.
            -- local title = "Thug"
            -- local subtitle = "Message"
            -- local iconType = 0
            -- local flash = false -- Flash doesn't seem to work no matter what.
            -- EndTextCommandThefeedPostMessagetext(txd, txd, flash, iconType, title, subtitle)

            -- -- Draw the notification
            -- local showInBrief = true
            -- local blink = false -- blink doesn't work when using icon notifications.
            -- EndTextCommandThefeedPostTicker(blink, showInBrief)
            
            -- -- Cleanup after yourself!
            -- UnregisterPedheadshot(handle)
        end

        if aiEnabled then
            ped = CreatePed(4, pedModel, spawns[spawnLocation].x, spawns[spawnLocation].y, spawns[spawnLocation].z, 0, true, true)
            SetPedIntoVehicle(ped, vehicle, -1)
            -- TaskVehicleDriveToCoord(ped, vehicle, destCoords.x, destCoords.y, destCoords.z, 30.0, 1.0, model, SetDriveTaskDrivingStyle(ped, 1074528293), 1.0, true)
            TaskVehicleDriveToCoordLongrange(ped, vehicle, destCoords.x, destCoords.y, destCoords.z, 30.0, SetDriveTaskDrivingStyle(ped, 1074528293), 1.0)
        end

        vehBlip = AddBlipForEntity(vehicle)
        SetBlipRoute(vehBlip, true)
        SetBlipColour(vehBlip, 5)
        SetBlipRouteColour(vehBlip, 5)

        while not IsPedInVehicle(PlayerPedId(), vehicle, false) do
            Citizen.Wait(500)
        end

        SetBlipRoute(vehBlip, false)
        RemoveBlip(vehBlip)

        destinationLocation = math.random(1, #destinations)
        destinationBlip = AddBlipForCoord(destinations[destinationLocation].x, destinations[destinationLocation].y, destinations[destinationLocation].z)
        SetBlipRoute(destinationBlip, true)
        SetBlipColour(destinationBlip, 5)
        SetBlipRouteColour(destinationBlip, 5)

        local playerCoords = GetEntityCoords(PlayerPedId())
        --print(playerCoords)
        --print(GetEntitySpeed(vehicle))
        --print(destinations[destinationLocation].x .. destinations[destinationLocation].y .. destinations[destinationLocation].z)
        --print(Vdist2(destinations[destinationLocation].x, destinations[destinationLocation].y, destinations[destinationLocation].z, playerCoords.x, playerCoords.y, playerCoords.z))
        while (Vdist2(destinations[destinationLocation].x, destinations[destinationLocation].y, destinations[destinationLocation].z, playerCoords.x, playerCoords.y, playerCoords.z) > 5 or GetEntitySpeed(vehicle) > 0) and IsVehicleDriveable(vehicle, true) do
            playerCoords = GetEntityCoords(PlayerPedId())
            Citizen.Wait(500)
        end

        local Player = QBCore.Functions.GetPlayerData()
        SetBlipRoute(destinationBlip, false)
        RemoveBlip(destinationBlip)
        if IsVehicleDriveable(vehicle, true) then
            TaskLeaveVehicle(PlayerPedId(), vehicle, 256)
            Citizen.Wait(2000)
            print(GetVehicleEngineHealth(vehicle))
            TriggerServerEvent("hiype-cardelivery:addMoney", Player.cid, (destinations[destinationLocation].from + GetVehicleEngineHealth(vehicle) + GetVehicleBodyHealth(vehicle)) / 2.0)
            QBCore.Functions.DeleteVehicle(vehicle)
        else
            QBCore.Functions.Notify("The vehicle was destroyed! Job has been canceled.", "error", 3000)
            Citizen.Wait(2000)
            QBCore.Functions.DeleteVehicle(vehicle)
        end
        isWorking = false
    end)
end

RequestModel(pedModel)
CreateThread(function()
    local notifSent = false

    RequestModel(pedModel)

    while not HasModelLoaded(pedModel) do
        Citizen.Wait(5)
    end

    npc = CreatePed(4, pedModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, npcHeading, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_DRUG_DEALER", 0, true)

    while true do
        Citizen.Wait(0)

        local pCoords = GetEntityCoords(PlayerPedId())
        if Vdist2(npcCoords, pCoords) < startSize and isLoggedIn then
            if IsControlPressed(0, 38) then
                if isWorking then
                    isWorking = false
                    QBCore.Functions.Notify("Car delivery job has been quit", "error", 3000)
                    QBCore.Functions.DeleteVehicle(vehicle)
                    DeletePed(ped)
                    Citizen.Wait(500)
                else 
                    if not cooldown then
                        isWorking = true
                        QBCore.Functions.Notify("Car delivery job started", "success", 3000)
                        carWithAi(aiEnabled)
                        Citizen.Wait(500)
                    else
                        TriggerServerEvent("hiype-cardelivery:request-cooldown-time")
                        Citizen.Wait(500)
                    end
                end

            else
                if not notifSent then
                    if not isWorking then
                        QBCore.Functions.Notify("Press E to start a job", "primary", 3000)
                    else
                        QBCore.Functions.Notify("Press E to quit the job", "primary", 3000)
                    end
                    notifSent = true
                end
            end
        else
            notifSent = false
        end
    end
end)