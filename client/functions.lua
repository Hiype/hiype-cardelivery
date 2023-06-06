local QBCore = exports['qb-core']:GetCoreObject()

function AddCustomBlip(sprite)
    if Config.AddBlip then
        local blip = AddBlipForCoord(Config.StartLocation.x, Config.StartLocation.y, Config.StartLocation.z)
        SetBlipSprite(blip, sprite)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Lang:t("info.blip_name"))
        EndTextCommandSetBlipName(blip)
        return blip
    else
        return nil
    end
end

function SetBoxZone(coords, length, width, minHeight, maxHeight, name_in)
    return BoxZone:Create(coords, length, width, {
        name=name_in,
        offset={0.0, 0.0, 0.0},
        scale={1.0, 1.0, 0.1},
        debugPoly=false,
        minZ=minHeight,
        maxZ=maxHeight,
    })
end

function StartJob(rank)
    local vehicleChoice
    local vehicle
    local model
    local spawnLocation
    local netid
    local vehBlip
    local destinationLocation
    local destinationBlip
    local cop
    local copVehicle
    local destinationBoxZone

    local pedid = PlayerPedId()

    TriggerServerEvent("hiype-cardelivery:server-start-cooldown")
    vehicleChoice = math.random(1, #Config.Vehicles[rank])
    model = Config.Vehicles[rank][vehicleChoice].model

    RequestModel(model)
    local modelLoadingTimeout = 5000
    while not HasModelLoaded(model) do
        Wait(10)
        modelLoadingTimeout = modelLoadingTimeout - 10
        if modelLoadingTimeout <= 0 then
            QBCore.Functions.Notify(Lang.t("error.car_model_timeout"), "error", 6000)
            jobActive = false
            print("ERROR: MODEL LOADING TIMED OUT FOR")
            print(vehicles[level][vehicleChoice].model)
            return
        end
    end

    if Config.Spawns == nil or #Config.Spawns < 1 then
        QBCore.Functions.Notify(Lang.t("error.no_spawn_in_config"), 'error', 5000)
        jobActive = false
        return
    end

    if #Config.Spawns >= 1 then
        spawnLocation = math.random(1, #Config.Spawns)
    else
        spawnLocation = #Config.Spawns
    end

    Wait(math.random(Config.MessageReceiveTimeStart, Config.MessageReceiveTimeEnd))

    if not jobActive then
        return
    end

    TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = Lang:t("info.message_name"),
        subject = Lang:t("info.message_subject"),
        message = string.format(Lang:t("info.message_text"), Config.Vehicles[rank][vehicleChoice].name, Config.Spawns[spawnLocation].name),
    })

    vehicle = CreateVehicle(model, Config.Spawns[spawnLocation].x, Config.Spawns[spawnLocation].y, Config.Spawns[spawnLocation].z, Config.Spawns[spawnLocation].heading, true, true)
    netid = NetworkGetNetworkIdFromEntity(vehicle)
    vehBlip = AddBlipForEntity(vehicle)

    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleDoorsLocked(vehicle, 2)
    SetVehicleNeedsToBeHotwired(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(model)
    SetBlipRoute(vehBlip, true)
    SetBlipColour(vehBlip, 5)
    SetBlipRouteColour(vehBlip, 5)

    while jobActive and not IsPedInVehicle(pedid, vehicle, true) and GetVehicleEngineHealth(vehicle) > 50 and IsVehicleDriveable(vehicle, false) do
        Wait(50)
    end

    SetBlipRoute(vehBlip, false)
    RemoveBlip(vehBlip)

    if GetVehicleEngineHealth() <= 50 or not IsVehicleDriveable(vehicle, false) or not jobActive then
        QBCore.Functions.Notify(Lang:t("error.vehicle_destroyed"), 'error', 7500)
        QBCore.Functions.Notify(string.format(Lang:t("info.xp_subtracted"), math.abs(Config.DestroyPenalty)), "error")
        TriggerServerEvent("hiype-cardelivery:server-update-metadata", Config.DestroyPenalty)
        jobActive = false
        Wait(5000)
        UpdateRank()
        return
    end

    destinationLocation = math.random(1, #Config.Destinations)
    destinationBlip = AddBlipForCoord(Config.Destinations[destinationLocation].x, Config.Destinations[destinationLocation].y, Config.Destinations[destinationLocation].z)
    SetBlipRoute(destinationBlip, true)
    SetBlipColour(destinationBlip, 5)
    SetBlipRouteColour(destinationBlip, 5)

    if Config.SendRealPoliceNotification then
        if math.random(1, Config.SendRealPoliceNotificationChance) == 1 then
            TriggerServerEvent('police:server:policeAlert', string.format(Lang:t("info.robbery_in_progress"), Config.Vehicles[rank][vehicleChoice].name))
        end
    end

    if Config.SpawnLocalPolice then
        if math.random(1, Config.SpawnLocalPoliceChance) == 1 then
            RequestModel(Config.VehicleModel)
            while not HasModelLoaded(Config.VehicleModel) do
                Wait(5)
            end

            RequestModel(Config.CopModel)
            while not HasModelLoaded(Config.CopModel) do
                Wait(5)
            end

            copVehicle = CreateVehicle(Config.VehicleModel, Config.Spawns[spawnLocation].copx, Config.Spawns[spawnLocation].copy, Config.Spawns[spawnLocation].copz, Config.Spawns[spawnLocation].copHeading, true, true)
            SetModelAsNoLongerNeeded(Config.VehicleModel)
            local veh_coords = GetEntityCoords(copVehicle)
            cop = CreatePed(4, Config.CopModel, veh_coords.x, veh_coords.y, veh_coords.z, 0, true, true)
            GiveWeaponToPed(cop, "weapon_pistol", 999, false, true)
            SetPedIntoVehicle(cop, copVehicle, -1)
            CopChase(cop, copVehicle, model)
        end
    end

    if jobActive then exports["qb-core"]:DrawText(Lang:t('info.keep_car'), 'left') end

    local destination_coords = vector3(Config.Destinations[destinationLocation].x, Config.Destinations[destinationLocation].y, Config.Destinations[destinationLocation].z)
    destinationBoxZone = SetBoxZone(destination_coords, 5, 5, destination_coords.z - 1, destination_coords.z + 4, "car_delivery_target")

    local choiceTimer = Config.KeepVehicleTimer
    local vehicle_coords

    while jobActive do
        Wait(100)
        vehicle_coords = GetEntityCoords(PlayerPedId())
        local inDestination = destinationBoxZone:isPointInside(vehicle_coords)
        if inDestination then
            BringVehicleToHalt(vehicle, 3.0, 1000, true)
            SetBlipRoute(destinationBlip, false)
            RemoveBlip(destinationBlip)
            if jobActive then
                SetEntityAsNoLongerNeeded(copVehicle)
                SetEntityAsNoLongerNeeded(cop)

                local extraPoints = GetVehicleEngineHealth(vehicle) + GetVehicleBodyHealth(vehicle)
                TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
                SeemlessDeleteVehicle(vehicle)
                if Config.PayoutBasedOnDistance then
                    TriggerServerEvent("hiype-cardelivery:server-add-money", math.floor(CalculateTravelDistanceBetweenPoints(Config.Spawns[spawnLocation].x, Config.Spawns[spawnLocation].y, Config.Spawns[spawnLocation].z, Config.Destinations[destinationLocation].x, Config.Destinations[destinationLocation].y, Config.Destinations[destinationLocation].z) / 2.0 + (extraPoints / 2.0) + rank * 1000))
                else
                    TriggerServerEvent("hiype-cardelivery:server-add-money", math.random(Config.Destinations[destinationLocation].from, Config.Destinations[destinationLocation].to) + (extraPoints / 2.0) + rank * 1000)
                end
                extraPoints = math.floor(extraPoints / 100)
                TriggerServerEvent("hiype-cardelivery:server-update-metadata", Config.JobXP + extraPoints)
                QBCore.Functions.Notify(string.format("Received %i XP", Config.JobXP + extraPoints), 'success')
                jobActive = false
                destinationBoxZone:destroy()
                Wait(5000)
                UpdateRank()
            end
        else
            if not IsVehicleDriveable(vehicle, false) or GetVehicleEngineHealth(vehicle) < 50 then
                SetBlipRoute(destinationBlip, false)
                RemoveBlip(destinationBlip)
                QBCore.Functions.Notify(Lang:t("error.vehicle_destroyed"), 'error', 7500)
                QBCore.Functions.Notify(string.format(Lang:t("info.xp_subtracted"), math.abs(Config.DestroyPenalty)), "error")
                TriggerServerEvent("hiype-cardelivery:server-update-metadata", Config.DestroyPenalty)
                exports["qb-core"]:HideText()
                jobActive = false
                Wait(5000)
                UpdateRank()
            end
            if choiceTimer > 0 then
                if IsControlPressed(0, 303) then -- U
                    SetBlipRoute(destinationBlip, false)
                    RemoveBlip(destinationBlip)
                    jobActive = false
                    QBCore.Functions.Notify(Lang:t("info.keep_car_job_cancelled"), 'primary')
                    QBCore.Functions.Notify(string.format(Lang:t("info.xp_subtracted"), math.abs(Config.KeepPenalty)), "error")
                    TriggerServerEvent("hiype-cardelivery:server-update-metadata", Config.KeepPenalty)
                    destinationBoxZone:destroy()
                    exports["qb-core"]:HideText()
                    Wait(5000)
                    UpdateRank()
                else
                    choiceTimer = choiceTimer - 100
                end
            else
                exports["qb-core"]:HideText()
            end
        end
    end
end

function CopChase(cop, copVehicle, model)
    local p_id = PlayerPedId()
    CreateThread(function()
        while cop and jobActive do
            Wait(8)
            local playerCoords = GetEntityCoords(p_id)
            if copVehicle then TaskVehicleDriveToCoord(cop, copVehicle, playerCoords.x, playerCoords.y, playerCoords.z, 30.0, 1.0, model, SetDriveTaskDrivingStyle(ped, 786603), 1.0, true) end
            TaskCombatPed(cop, p_id, 0, 16)
        end
    end)
end

function SeemlessDeleteVehicle(vehicle)
    CreateThread(function()
        local timeout = Config.VehicleDeleteTimeout
        while vehicle and timeout > 0 do
            Wait(500)
            timeout = timeout - 500
            local player_coords = GetEntityCoords(PlayerPedId())
            local vehicle_coords = GetEntityCoords(vehicle)
            if Vdist2(player_coords, vehicle_coords) > 2000 then break end
        end
        QBCore.Functions.DeleteVehicle(vehicle)
    end)
end

function IsPlayerCop()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.label == 'Law Enforcement' then
        return true
    else
        return false
    end
end