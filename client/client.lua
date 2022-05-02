local QBCore = exports['qb-core']:GetCoreObject()

local startBoxZone
local blip
local rank
local startPed
local jobVehicle
local CurrentCops

local insideStartZone = false

jobActive = false

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

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

    RequestModel(Config.StartPedModel)

    while not HasModelLoaded(Config.StartPedModel) do
        Wait(10)
    end

    startPed = CreatePed(4, Config.StartPedModel, startLocation.x, startLocation.y, startLocation.z - 1, startLocation.w, false, true)
    FreezeEntityPosition(startPed, true)
    SetEntityInvincible(startPed, true)
    SetBlockingOfNonTemporaryEvents(startPed, true)
    TaskStartScenarioInPlace(startPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)

    while not rank do
        Wait(500)
    end

    if Config.UseTarget then
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
                            if CurrentCops >= Config.MinimumCopCount then
                            QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-cooldown-status", function(result)
                                local cooldown = result
                                if not cooldown then
                                    jobActive = true
                                    StartJob(rank)
                                else
                                    QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-cooldown-timer", function(result)
                                        local secondsLeft = result
                                        QBCore.Functions.Notify(string.format("Cooldown: %i seconds left", secondsLeft), 'primary')
                                    end)
                                end
                            end)
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
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
end)

AddEventHandler('onResourceStart', function(resource)
    TriggerServerEvent('police:server:UpdateCurrentCops')
    QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-rank", function(result)
        rank = result
    end)
    
    local startLocation = Config.StartLocation
    if resource == GetCurrentResourceName() then
        Wait(100)
        LocalPlayer.state:set('isLoggedIn', true, false)
    end

    RequestModel(Config.StartPedModel)

    while not HasModelLoaded(Config.StartPedModel) do
        Wait(10)
    end

    startPed = CreatePed(4, Config.StartPedModel, startLocation.x, startLocation.y, startLocation.z - 1, startLocation.w, false, true)
    FreezeEntityPosition(startPed, true)
    SetEntityInvincible(startPed, true)
    SetBlockingOfNonTemporaryEvents(startPed, true)
    TaskStartScenarioInPlace(startPed, "WORLD_HUMAN_DRUG_DEALER", 0, true)

    while not rank do
        Wait(500)
    end

    if Config.UseTarget then
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
                            if CurrentCops >= Config.MinimumCopCount then
                                QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-cooldown-status", function(result)
                                    local cooldown = result
                                    if not cooldown then
                                        jobActive = true
                                        StartJob(rank)
                                    else
                                        QBCore.Functions.TriggerCallback("hiype-cardelivery:server-get-cooldown-timer", function(result)
                                            local secondsLeft = result
                                            QBCore.Functions.Notify(string.format("Cooldown: %i seconds left", secondsLeft), 'primary')
                                        end)
                                    end
                                end)
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

function UpdateRank()
    TriggerServerEvent("hiype-cardelivery:server-return-rank")
end