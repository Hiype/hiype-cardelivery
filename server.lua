local QBCore = exports['qb-core']:GetCoreObject()
local metaDataName = "cardeliveryxp"

RegisterNetEvent("hiype_cardelivery:start_cooldown")
AddEventHandler("hiype_cardelivery:start_cooldown", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    cdCooldown = true
    TriggerClientEvent("hiype-cardelivery:update-cooldown", -1, cdCooldown)

    if Player.PlayerData.metadata[metaDataName] ~= nil then
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, Player.PlayerData.metadata[metaDataName])
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

    if Player.PlayerData.metadata[metaDataName] ~= nil then
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, Player.PlayerData.metadata[metaDataName])
    else
        TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, 0)
    end
end)

RegisterNetEvent('hiype-cardelivery:SetMetaData', function(meta, data)
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
    end
    TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
end)

function UpdateRank(change, metadata)
    change = tonumber(change)

    if metadata + change < 0 then
        change = metadata * -1
    end

    TriggerServerEvent('hiype-cardelivery:SetMetaData', metaDataName, metadata + change)
end

function SetRank(change)
    change = tonumber(change)

    if change < 0 then 
        change = 0 
    end

    TriggerServerEvent('hiype-cardelivery:SetMetaData', metaDataName, change)
end

QBCore.Commands.Add(metaDataName, 'Check/Edit car delivery rank', { { name = 'option', help = 'Option type (rank, add, set)' }, { name = 'number', help = 'Set or add rank by (type in anoythin for rank option)'} }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local metadata = Player.PlayerData.metadata[metaDataName]

    if args[1] == "rank" then
        if metadata ~= nil then
            TriggerClientEvent("QBCore:Notify", source, "Current rank " .. metadata, "primary")
        else
            TriggerClientEvent("QBCore:Notify", source, "Current rank nil", "primary")
        end
    else
        if args[1] == "add" then
                UpdateRank(args[2], metadata)
        else
            if args[1] == "set" then
                SetRank(args[2])
            else
                TriggerClientEvent("QBCore:Notify", source, "No such parameter", "error")
            end 
        end
    end
end, 'admin')

function RefreshCommands(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(QBCore.Commands.List) do
            local isGod = QBCore.Functions.HasPermission(src, 'god')
            local hasPerm = QBCore.Functions.HasPermission(src, QBCore.Commands.List[command].permission)
            local isPrincipal = IsPlayerAceAllowed(src, 'command')
            if isGod or hasPerm or isPrincipal then
                suggestions[#suggestions + 1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            end
        end
        TriggerClientEvent('chat:addSuggestions', tonumber(source), suggestions)
    end
end

RefreshCommands(source)