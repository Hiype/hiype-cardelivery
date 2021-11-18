local isWorking = false
local vehicle = nil
local vehicleChoice = nil
local ped = nil
local cooldown = nil
local spawnLocation = nil
local destinationLocation = nil
local vehBlip = nil
local destinationBlip = nil
local spawns = nil
local spawnDriving = false
local player = nil
local isLoggedIn = false
local startEntitySpawned = false
local table = nil
local laptop = nil
local npc = nil
local rank = nil

local timeout = 0
local tableModel = GetHashKey("prop_table_03b")
local laptopModel = GetHashKey("prop_laptop_01a")

RegisterNetEvent('hiype-cardelivery:client-receive-rank')
AddEventHandler('hiype-cardelivery:client-receive-rank', function(rank_in)
    rank = rank_in
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent("qb-clothes:loadPlayerSkin")
    TriggerServerEvent('hiype-cardelivery:GetMetaData')
    isLoggedIn = true
    player = PlayerPedId()

    if not startEntitySpawned then
        CreateThread(function()
            if not showNpc then
                RequestModel(tableModel)
                while not HasModelLoaded(tableModel) do
                    Citizen.Wait(5)
                end

                RequestModel(laptopModel)
                while not HasModelLoaded(laptopModel) do
                    Citizen.Wait(5)
                end


                table = CreateObject(tableModel, npcCoords.x, npcCoords.y, npcCoords.z - 0.99, false, true, false)
                laptop = CreateObject(laptopModel, npcCoords.x, npcCoords.y, npcCoords.z - 0.2, false, true, false)
            
                FreezeEntityPosition(table, true)
                FreezeEntityPosition(laptop, true)
            else
                RequestModel(pedModel)

                while not HasModelLoaded(pedModel) do
                    Citizen.Wait(5)
                end
                
                npc = CreatePed(4, pedModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, npcHeading, false, true)
                FreezeEntityPosition(npc, true)
                SetEntityInvincible(npc, true)
                SetBlockingOfNonTemporaryEvents(npc, true)
                TaskStartScenarioInPlace(npc, "WORLD_HUMAN_DRUG_DEALER", 0, true)
            end
            startEntitySpawned = true
        end)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

-- Allows the ability to reload this resource live
-- Remove the if for live version
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        player = PlayerPedId()
        isLoggedIn = true
    end

    TriggerServerEvent('hiype-cardelivery:GetMetaData')

    if not startEntitySpawned then
        CreateThread(function()
            if not showNpc then
                RequestModel(tableModel)
                while not HasModelLoaded(tableModel) do
                    Citizen.Wait(5)
                end

                RequestModel(laptopModel)
                while not HasModelLoaded(laptopModel) do
                    Citizen.Wait(5)
                end


                table = CreateObject(tableModel, npcCoords.x, npcCoords.y, npcCoords.z - 0.99, false, true, false)
                laptop = CreateObject(laptopModel, npcCoords.x, npcCoords.y, npcCoords.z - 0.2, false, true, false)
            
                FreezeEntityPosition(table, true)
                FreezeEntityPosition(laptop, true)
            else
                RequestModel(pedModel)

                while not HasModelLoaded(pedModel) do
                    Citizen.Wait(5)
                end
                
                npc = CreatePed(4, pedModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, npcHeading, false, true)
                FreezeEntityPosition(npc, true)
                SetEntityInvincible(npc, true)
                SetBlockingOfNonTemporaryEvents(npc, true)
                TaskStartScenarioInPlace(npc, "WORLD_HUMAN_DRUG_DEALER", 0, true)
            end
            startEntitySpawned = true
        end)
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
        if math.random(0, 10) % 2 == 1 then
            spawns = drive_spawns
            spawnDriving = true
            print("Car will be driving around!")
        else
            spawns = parked_spawns
            print("Car will be parked!")
        end

        if spawns == nil or #spawns < 1 then
            QBCore.Functions.Notify("No spawn locations in config file, quitting the job", 'error', 5000)
            isWorking = false
            return
        end

        if #spawns >= 1 then
            spawnLocation = math.random(1, #spawns)
        else
            spawnLocation = #spawns
        end

        vehicle = CreateVehicle(model, spawns[spawnLocation].x, spawns[spawnLocation].y, spawns[spawnLocation].z, spawns[spawnLocation].heading, true, true)
        local netid = NetworkGetNetworkIdFromEntity(vehicle)

        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetNetworkIdCanMigrate(netid, true)

        if spawnDriving then
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleNeedsToBeHotwired(vehicle, false)
        else
            SetVehicleDoorsLocked(vehicle, 2)
            SetVehicleNeedsToBeHotwired(vehicle, true)
        end

        SetEntityAsMissionEntity(vehicle, true, true)
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

        local zCoord = 0
        player = PlayerPedId()
        while not IsPedInVehicle(player, vehicle, true) and isWorking and IsVehicleDriveable(vehicle, true) and GetVehicleEngineHealth(vehicle) > 50 do
            Citizen.Wait(5)
            if showNpc then
                zCoord = npcCoords.z + 1
            else
                zCoord = npcCoords.z
            end

            if spawnDriving then
                TaskVehicleDriveWander(driver, veh, 15.0, SetDriveTaskDrivingStyle(ped, 786603))
            end
            
            timeout = timeout + 0.5
            if notification and timeout < 200 and showAboveHead then
                if spawnDriving then
                    DrawText3D(npcCoords.x, npcCoords.y, zCoord, "Go find a ~g~" .. vehicles[vehicleChoice].name .. " ~w~somewhere around ~g~" .. spawns[spawnLocation].name .. "!")
                else
                    DrawText3D(npcCoords.x, npcCoords.y, zCoord, "Go get a parked ~g~" .. vehicles[vehicleChoice].name .. "~w~ at ~g~" .. spawns[spawnLocation].name .. "!")
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

        local vehCoords = GetEntityCoords(vehicle)
        local countdown = choiceTimer * 1000

        if IsVehicleDriveable(vehicle, true) and GetVehicleEngineHealth(vehicle) > 50 then
            QBCore.Functions.Notify("In the next " .. choiceTimer .. " seconds, press U to keep the car and leave the job", "primary", 6000)
        end

        while (Vdist2(destinations[destinationLocation].x, destinations[destinationLocation].y, destinations[destinationLocation].z, vehCoords.x, vehCoords.y, vehCoords.z) > 15 or GetEntitySpeed(vehicle) > 0) and IsVehicleDriveable(vehicle, true) and GetVehicleEngineHealth(vehicle) > 50 and isWorking do
            Citizen.Wait(8)
            vehCoords = GetEntityCoords(vehicle)
            if abilityToKeepVehicle and countdown > choiceTimer then
                if IsControlPressed( 0, 303) then
                    isWorking = false
                    UpdateRank(rankPenalty)
                    
                    QBCore.Functions.Notify("Keep the car, job is canceled", "primary", 5000)
                    QBCore.Functions.Notify(tostring(rankPenalty) .. " XP subtracted from car delivery rank", "error", 5000)
                    Citizen.Wait(300)
                end
                countdown = countdown - 8
            end
        end

        SetBlipRoute(destinationBlip, false)
        RemoveBlip(destinationBlip)

        if isWorking then
            if GetVehicleEngineHealth(vehicle) > 50 and IsVehicleDriveable(vehicle, true) then
                local extraPoints = GetVehicleEngineHealth(vehicle) + GetVehicleBodyHealth(vehicle)
                TaskLeaveVehicle(PlayerPedId(), vehicle, 256)
                Citizen.Wait(2000)
                TriggerServerEvent("hiype-cardelivery:addMoney", math.random(destinations[destinationLocation].from, destinations[destinationLocation].to) + (extraPoints / 2.0))

                extraPoints = math.floor(extraPoints / 10.0)
                UpdateRank(100 + extraPoints)
                QBCore.Functions.Notify("Added " .. (100 + extraPoints) .. " xp to car delivery rank", "success", 5000)
                QBCore.Functions.DeleteVehicle(vehicle)
            else
                UpdateRank(rankPenalty)
                QBCore.Functions.Notify("The vehicle was destroyed! Job has been canceled.", "error", 3000)
                QBCore.Functions.Notify("120 XP subtracted from car delivery rank", "error", 5000)
                Citizen.Wait(2000)
                QBCore.Functions.DeleteVehicle(vehicle)
            end
        end
        isWorking = false
    end)
end

CreateThread(function()
    local notifSent = false

    while true do
        Citizen.Wait(10)
        local pCoords = GetEntityCoords(PlayerPedId())

        if Vdist2(npcCoords, pCoords) < startSize and isLoggedIn then
            timeout = 0
            if IsControlPressed(0, 38) then
                if isWorking then
                    isWorking = false
                    QBCore.Functions.Notify("Car delivery job has been quit", "error", 3000)
                    QBCore.Functions.DeleteVehicle(vehicle)
                    DeletePed(ped)
                    timeout = 200
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

-- Code taken from QBCore resources, QBCore.Functions.DrawText3D
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

function UpdateRank(change)
    change = tonumber(change)

    if rank == nil then
        TriggerServerEvent('hiype-cardelivery:GetMetaData')
    end

    if rank + change < 0 then
        change = rank * -1
    end

    while true do
        Citizen.Wait(500)

        if rank ~= nil then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'cardeliveryxp', rank + change)
            rank = rank + change
            break
        else
            TriggerServerEvent('hiype-cardelivery:GetMetaData')
        end
    end
end

function SetRank(change)
    change = tonumber(change)

    while true do
        Citizen.Wait(500)

        if rank ~= nil then
            TriggerServerEvent('QBCore:Server:SetMetaData', 'cardeliveryxp', change)
            rank = rank + change
            break
        else
            TriggerServerEvent('hiype-cardelivery:GetMetaData')
        end
    end
end

RegisterCommand('cardelivery', function(source, args, rawCommand)
    if args[1] == "rank" then
        TriggerServerEvent('hiype-cardelivery:GetMetaData')
        if rank ~= nil then
            QBCore.Functions.Notify("Current rank " .. rank, "primary")
        else
            QBCore.Functions.Notify("Current rank nil", "primary")
            TriggerServerEvent('hiype-cardelivery:GetMetaData')
        end
    else
        if args[1] == "add" then
                UpdateRank(args[2])
        else
            if args[1] == "set" then
                SetRank(args[2])
            else
                QBCore.Functions.Notify("No such parameter", "error")
            end 
        end
    end
end, false)