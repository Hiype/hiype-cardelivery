RegisterNetEvent("hiype_cardelivery:start_cooldown")
AddEventHandler("hiype_cardelivery:start_cooldown", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    cdCooldown = true
    TriggerClientEvent("hiype-cardelivery:update-cooldown", -1, cdCooldown)

    if Player.PlayerData.metadata['cardeliveryxp'] ~= nil then
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, Player.PlayerData.metadata['cardeliveryxp'])
    else
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, 0)
    end
    CreateThread(function()
        for i=cooldown, 0, -1 do
            Citizen.Wait(1000)
            secondsLeft = i
        end
        
        cdCooldown = false
        TriggerClientEvent("hiype-cardelivery:update-cooldown", -1, cdCooldown)
    end)
end)

RegisterNetEvent("hiype-cardelivery:cooldown-request")
AddEventHandler("hiype-cardelivery:cooldown-request", function()
    local src = source
    local playerId = GetPlayerFromServerId(src)
    TriggerClientEvent("hiype-cardelivery:update-cooldown", src, cdCooldown)
end)

RegisterNetEvent("hiype-cardelivery:request-cooldown-time")
AddEventHandler("hiype-cardelivery:request-cooldown-time", function()
    TriggerClientEvent("QBCore:Notify", source, "Cooldown - " .. secondsLeft .. " seconds left", "primary", 3000)
end)

RegisterNetEvent("hiype-cardelivery:addMoney")
AddEventHandler("hiype-cardelivery:addMoney", function(amount)
    local src = source
    if payInCash then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney("cash", amount)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney("bank", amount)
    end
end)

RegisterNetEvent('hiype-cardelivery:GetMetaData', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.PlayerData.metadata['cardeliveryxp'] ~= nil then
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, Player.PlayerData.metadata['cardeliveryxp'])
    else
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, 0)
    end
end)

RegisterNetEvent('QBCore:Server:SetMetaData', function(meta, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if meta == 'hunger' or meta == 'thirst' then
        if data > 100 then
            data = 100
        end
    end
    if Player then
        Player.Functions.SetMetaData(meta, data)
        TriggerClientEvent('hiype-cardelivery:client-receive-rank', src, data)
        print("CAR DELIVERY XP SET TO " .. data)
    end
    TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
end)