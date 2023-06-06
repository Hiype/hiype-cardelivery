local QBCore = exports['qb-core']:GetCoreObject()

local startBoxZone
local blip
local rank
local startPed
local netStartPed
local jobVehicle
local CurrentCops = 0

local insideStartZone = false

jobActive = false

function UpdateRank()
    TriggerServerEvent("hiype-cardelivery:server-return-rank")
end

local function UpdateCopCount()
    QBCore.Functions.TriggerCallback('hiype-cardelivery:server:fetch-cop-count', function(result)
        CurrentCops = result
    end)
end

function AddTargetToEntity()
    
    startPed = NetToEnt(netStartPed)
    exports['qb-target']:AddTargetEntity(startPed, {
        options = {
            {
                type = "client",
                icon = "fa-solid fa-car",
                label = Lang:t('info.start_job2'),
                action = function(entity)
                    if jobActive then
                        QBCore.Functions.Notify(Lang:t('error.job_in_progress'), "error")
                    else
                        if Config.MinimumCopCount > 0 then UpdateCopCount() end
                        if CurrentCops >= Config.MinimumCopCount then
                            QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-cooldown-status", function(result)
                                local cooldown = result
                                if not cooldown then
                                    if Config.ProhibitCopsFromStartingJob and not IsPlayerCop() or not Config.ProhibitCopsFromStartingJob then
                                        jobActive = true
                                        StartJob(rank)
                                    else
                                        QBCore.Functions.Notify(Lang:t('error.cops_cant_start_job'), 'error')
                                    end
                                else
                                    if not IsPlayerCop() then
                                    QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-cooldown-timer", function(result)
                                        local secondsLeft = result
                                        QBCore.Functions.Notify(string.format(Lang:t('info.cooldown_left'), secondsLeft), 'primary')
                                    end)
                                end
                            end end)
                        else
                            QBCore.Functions.Notify(Lang:t("error.not_enough_cops"), 'error')
                        end
                    end
                end
            },
            {
                type = "client",
                icon = "fa-solid fa-x",
                label = Lang:t('info.end_job2'),
                action = function(entity)
                    if jobActive then
                        jobActive = false
                        QBCore.Functions.Notify(Lang:t('error.job_quit'), "error")
                        QBCore.Functions.DeleteVehicle(jobVehicle)
                    else 
                        QBCore.Functions.Notify(Lang:t('error.job_not_active'), "error")
                    end
                end
            },
        },
        distance = 3.0
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback("hiype-cardelivery:server-metadata-available", function(result)
        if result then
            QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-rank", function(result)
                rank = result
            end)
        else
            QBCore.Functions.Notify(Lang.t("error.metadata_not_set_up"), 'error', 6000)
        end
    end)

    local startLocation = Config.StartLocation
    LocalPlayer.state:set('isLoggedIn', true, false)

    QBCore.Functions.TriggerCallback('hiype-cardelivery:server-get-net-start-ped', function(netStartPed_in)
        netStartPed = netStartPed_in
        startPed = NetToEnt(netStartPed)
        SetEntityInvincible(startPed, true)
        SetBlockingOfNonTemporaryEvents(startPed, true)
        TaskStartScenarioInPlace(startPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
    end)

    while not rank do
        Wait(500)
    end

    if Config.UseTarget then
        AddTargetToEntity()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
    jobActive = false
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	DeleteVehicle(jobVehicle)
end)

RegisterNetEvent('hiype-cardelivery:client-update-start', function(netStartPed_in)
    netStartPed = netStartPed_in
    startPed = NetToEnt(netStartPed)
    SetEntityInvincible(startPed, true)
    SetBlockingOfNonTemporaryEvents(startPed, true)
    TaskStartScenarioInPlace(startPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(100)
        LocalPlayer.state:set('isLoggedIn', true, false)
    else
        return
    end

    if Config.MinimumCopCount > 0 then UpdateCopCount() end
    
    QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-rank", function(result)
        rank = result
    end)
    
    local startLocation = Config.StartLocation

    QBCore.Functions.TriggerCallback('hiype-cardelivery:server-get-net-start-ped', function(netStartPed_in)
        netStartPed = netStartPed_in
        startPed = NetToEnt(netStartPed)
        SetEntityInvincible(startPed, true)
        SetBlockingOfNonTemporaryEvents(startPed, true)
        TaskStartScenarioInPlace(startPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
    end)

    while not rank do
        Wait(500)
    end

    if Config.UseTarget then
        AddTargetToEntity()
    end
end)

RegisterNetEvent("hiype-cardelivery:client-receive-rank", function(rank_in)
    local currentRank = rank
    rank = rank_in
    if currentRank and rank > currentRank then
        QBCore.Functions.Notify(string.format(Lang:t("info.rank"), rank), "success", 5000)
        QBCore.Functions.Notify(Lang:t("info.rank_up"), "success", 5000)
    else
        if currentRank and rank < currentRank then
            QBCore.Functions.Notify(string.format(Lang:t("info.rank"), rank), "error", 5000)
            QBCore.Functions.Notify(Lang:t("error.rank_lost"), "error", 5000)
        end
    end
end)

CreateThread(function()
    if Config.AddBlip then
        blip = AddCustomBlip(524)
    end

    if not Config.UseTarget then
        startBoxZone = SetBoxZone(Config.StartLocation, 6.0, 6.0, "start_box_zone")
        startBoxZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
            insideStartZone = isPointInside
        end, 100)
    end

    areaBoxZone = SetBoxZone(Config.StartLocation, 100.0, 100.0, "area_box_zone")
    areaBoxZone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
        startPed = NetToEnt(netStartPed)
        SetEntityInvincible(startPed, true)
        SetBlockingOfNonTemporaryEvents(startPed, true)
        TaskStartScenarioInPlace(startPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)
        AddTargetToEntity()
    end, 1000)
    
    if Config.MinimumCopCount > 0 then UpdateCopCount() end

    while true do
        if not insideStartZone then Wait(200) else Wait(10) end
        if LocalPlayer.state['isLoggedIn'] then
            if insideStartZone then
                if not jobActive then
                    if CurrentCops >= Config.MinimumCopCount then
                        if not Config.UseTarget then exports["qb-core"]:DrawText(Lang:t('info.start_job'), 'left') end
                        if IsControlPressed(0, 38) then -- Key E
                            jobActive = true
                            if not Config.UseTarget then exports["qb-core"]:HideText() end
                            StartJob(rank)
                            Wait(500)
                        end
                    else
                        QBCore.Functions.Notify(Lang:t("error.not_enough_cops"), 'error')
                    end
                else
                    if not Config.UseTarget then exports["qb-core"]:DrawText(Lang:t('info.end_job'), 'left') end
                    if IsControlPressed(0, 38) then -- Key E
                        jobActive = false
                        if not Config.UseTarget then exports["qb-core"]:HideText() end
                        Wait(500)
                    end
                end
            else
                if not Config.UseTarget then exports["qb-core"]:HideText() end
            end
        end
    end
end)