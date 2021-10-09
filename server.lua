RegisterNetEvent("hiype_cardelivery:start_cooldown")
AddEventHandler("hiype_cardelivery:start_cooldown", function()
    cdCooldown = true
    TriggerClientEvent("hiype-cardelivery:update-cooldown", -1, cdCooldown)
    CreateThread(function()

        --Waits 120 seconds / 2 minutes
        for i=120, 0, -1 do
            Citizen.Wait(1000)
            secondsLeft = i
        end
        cdCooldown = false
        TriggerClientEvent("hiype-cardelivery:update-cooldown", -1, cdCooldown)
    end)
end)

RegisterNetEvent("hiype-cardelivery:cooldown-request")
AddEventHandler("hiype-cardelivery:cooldown-request", function()
    local playerId = GetPlayerFromServerId(source)
    TriggerClientEvent("hiype-cardelivery:update-cooldown", source, cdCooldown)
end)

RegisterNetEvent("hiype-cardelivery:request-cooldown-time")
AddEventHandler("hiype-cardelivery:request-cooldown-time", function()
    TriggerClientEvent("QBCore:Notify", source, "Cooldown - " .. secondsLeft .. " seconds left", "primary", 3000)
end)

RegisterNetEvent("hiype-cardelivery:addMoney")
AddEventHandler("hiype-cardelivery:addMoney", function(id, amount)
    local Player = QBCore.Functions.GetPlayer(id)
    Player.Functions.AddMoney("cash", amount)
end)