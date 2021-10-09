local npcHeading = 205.9
local npcCoords = vector3(-79.25, -1392.6, 29.32)

local spawnHeading = 212.84
local spawnCoords = vector3(-91.94, -1406.96, 29.32)

local destCoords = vector3(-79.69, -1409.46, 29.32)

local pedModel = GetHashKey("g_m_y_lost_01")

local isWorking = false
local vehicle = nil
local vehicleChoice = nil
local ped = nil
local npc = nil
local cooldown = nil
local spawnLocation = nil
local destinationLocation = nil
local vehBlip = nil
local destinationBlip = nil

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

function createPed()
    npc = CreatePed(4, pedModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, npcHeading
, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_DRUG_DEALER", 0, true)
end

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

        SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
        SetNetworkIdCanMigrate(netid, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)

        -- Get the ped headshot image
        local handle = RegisterPedheadshot(npc)
        while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
            Citizen.Wait(0)
        end
        local txd = GetPedheadshotTxdString(handle)

        -- Add the notification text
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("Go get a ~r~" .. vehicles[vehicleChoice].name .. "~w~ in ~g~" .. spawns[spawnLocation].name)
        
        -- Set the notification icon, title and subtitle.
        local title = "Thug"
        local subtitle = "Message"
        local iconType = 0
        local flash = false -- Flash doesn't seem to work no matter what.
        EndTextCommandThefeedPostMessagetext(txd, txd, flash, iconType, title, subtitle)

        -- Draw the notification
        local showInBrief = true
        local blink = false -- blink doesn't work when using icon notifications.
        EndTextCommandThefeedPostTicker(blink, showInBrief)
        
        -- Cleanup after yourself!
        UnregisterPedheadshot(handle)

        if aiEnabled then
            ped = CreatePed(4, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, true)
            SetPedIntoVehicle(ped, vehicle, -1)
            TaskVehicleDriveToCoord(ped, vehicle, destCoords.x, destCoords.y, destCoords.z, 30.0, 1.0, model, SetDriveTaskDrivingStyle(ped, 1074528293), 1.0, true)
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
            print(playerCoords)
            print(GetEntitySpeed(vehicle))
            Citizen.Wait(500)
        end

        local Player = QBCore.Functions.GetPlayerData()
        SetBlipRoute(destinationBlip, false)
        RemoveBlip(destinationBlip)
        if IsVehicleDriveable(vehicle, true) then
            TaskLeaveVehicle(PlayerPedId(), vehicle, 256)
            Citizen.Wait(2000)
            print(GetVehicleEngineHealth(vehicle))
            TriggerServerEvent("hiype-cardelivery:addMoney", Player.cid, destinations[destinationLocation].from + GetVehicleEngineHealth(vehicle))
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

    while not HasModelLoaded(pedModel) do
        Citizen.Wait(1)
    end

    createPed()

    local playerPed = PlayerPedId()
    while true do
        Citizen.Wait(4)

        local playerCoords = GetEntityCoords(playerPed)
        if Vdist2(npcCoords, playerCoords) < 20 then
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
                        carWithAi(false)
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