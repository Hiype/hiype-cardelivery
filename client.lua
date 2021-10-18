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
local spawns = nil
local spawnDriving = false
local player = nil
local isLoggedIn = false

local timeout = 0

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

-- Allows the ability to reload this resource live
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
end)

-- Adds a blip
local blip = AddBlipForCoord(npcCoords.x, npcCoords.y, npcCoords.z)
SetBlipSprite(blip, 524)
SetBlipScale(blip, 0.8)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Car delivery")
EndTextCommandSetBlipName(blip)

function carWithAi()
    CreateThread(function()
        TriggerServerEvent("hiype_cardelivery:start_cooldown")
        vehicleChoice = math.random(1, #vehicles)
        local model = GetHashKey(vehicles[vehicleChoice].model)

        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        -- Decides if the car should spawn parked or driving (Will be made soon)
        if false then
            spawns = drive_spawns
            spawnDriving = true
            print("Car will be driving around!")
        else
            spawns = parked_spawns
            print("Car will be parked!")
        end

        spawnLocation = math.random(1, #spawns)
        vehicle = CreateVehicle(model, spawns[spawnLocation].x, spawns[spawnLocation].y, spawns[spawnLocation].z, spawns[spawnLocation].heading, true, true)
        local netid = NetworkGetNetworkIdFromEntity(vehicle)

        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetNetworkIdCanMigrate(netid, true)
        SetVehicleNeedsToBeHotwired(vehicle, true)
        SetModelAsNoLongerNeeded(model)

        if spawnDriving then
            ped = CreatePed(4, pedModel, spawns[spawnLocation].x, spawns[spawnLocation].y, spawns[spawnLocation].z, 0, true, true)
            SetPedIntoVehicle(ped, vehicle, -1)
            TaskVehicleDriveWander(driver, veh, 15.0, SetDriveTaskDrivingStyle(ped, 786603))
        end

        vehBlip = AddBlipForEntity(vehicle)
        SetBlipRoute(vehBlip, true)
        SetBlipColour(vehBlip, 5)
        SetBlipRouteColour(vehBlip, 5)

        if notification and not showAboveHead then
            if spawnDriving then
                QBCore.Functions.Notify("Go find a " .. vehicles[vehicleChoice].name .. " somewhere around " .. spawns[spawnLocation].name .. "!", "success", 3500)
            else
                QBCore.Functions.Notify("Go get a parked " .. vehicles[vehicleChoice].name .. " at " .. spawns[spawnLocation].name .. "!", "success", 3500)
            end
        end

        while not IsPedInVehicle(player, vehicle, false) and isWorking do
            Citizen.Wait(5)
            timeout = timeout + 1
            if notification and timeout < 200 and showAboveHead then
                if spawnDriving then
                    DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1, "Go find a ~g~" .. vehicles[vehicleChoice].name .. " ~w~somewhere around ~g~" .. spawns[spawnLocation].name .. "!")
                else
                    DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1, "Go get a parked ~g~" .. vehicles[vehicleChoice].name .. "~w~ at ~g~" .. spawns[spawnLocation].name .. "!")
                end
            end
            
        end

        SetBlipRoute(vehBlip, false)
        RemoveBlip(vehBlip)

        destinationLocation = math.random(1, #destinations)
        destinationBlip = AddBlipForCoord(destinations[destinationLocation].x, destinations[destinationLocation].y, destinations[destinationLocation].z)
        SetBlipRoute(destinationBlip, true)
        SetBlipColour(destinationBlip, 5)
        SetBlipRouteColour(destinationBlip, 5)

        local playerCoords = GetEntityCoords(PlayerPedId())
        while (Vdist2(destinations[destinationLocation].x, destinations[destinationLocation].y, destinations[destinationLocation].z, playerCoords.x, playerCoords.y, playerCoords.z) > 8 or GetEntitySpeed(vehicle) > 0) and IsVehicleDriveable(vehicle, true) and isWorking do
            playerCoords = GetEntityCoords(PlayerPedId())
            Citizen.Wait(500)
        end

        local Player = QBCore.Functions.GetPlayerData()
        SetBlipRoute(destinationBlip, false)
        RemoveBlip(destinationBlip)
        if isWorking then
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
            timeout = 0
            if IsControlPressed(0, 38) then
                if isWorking then
                    isWorking = false
                    QBCore.Functions.Notify("Car delivery job has been quit", "error", 3000)
                    QBCore.Functions.DeleteVehicle(vehicle)
                    timeout = 200
                    DeletePed(ped)
                    Citizen.Wait(500)
                else 
                    if not cooldown then
                        isWorking = true
                        QBCore.Functions.Notify("Car delivery job started", "success", 3000)
                        carWithAi()
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

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end