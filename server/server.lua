local QBCore = exports["qb-core"]:GetCoreObject()
local metaDataName = "cardeliveryxp"
local cooldownTimer = 0
local startPed
local netStartPed

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

	local startLocation = Config.StartLocation
	startPed = CreatePed(4, Config.StartPedModel, startLocation.x, startLocation.y, startLocation.z - 1, startLocation.w, true, true)
	netStartPed = NetworkGetNetworkIdFromEntity(startPed)
	FreezeEntityPosition(startPed, true)
	TriggerClientEvent('hiype-cardelivery:client-update-start', -1, startPed)
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	DeleteEntity(startPed)
end)

RegisterNetEvent("hiype-cardelivery:server-start-cooldown", function()
    cooldownTimer = Config.CooldownTime * 1000
    CreateThread(function()
        while cooldownTimer > 0 do
            Wait(1000)
            cooldownTimer = cooldownTimer - 1000
        end
    end)
end)

RegisterNetEvent("hiype-cardelivery:server-add-money", function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney(Config.PayoutMethod, amount)
end)

RegisterNetEvent("hiype-cardelivery:server-update-metadata", function(value)
	changeMetaData(source, value)
end)

RegisterNetEvent("hiype-cardelivery:server-return-rank", function()
	local src = source
	TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, updateRank(src))
end)

QBCore.Functions.CreateCallback("hiype-cardelivery:server-get-cooldown-status", function(name, cb)
    if cooldownTimer <= 0 then
        cb(false)
    else
        cb(true)
    end
end)

QBCore.Functions.CreateCallback("hiype-cardelivery:server-get-cooldown-timer", function(name, cb)
    cb(cooldownTimer / 1000)
end)

QBCore.Functions.CreateCallback("hiype-cardelivery:server-get-rank", function(source, cb)
	local src = source
	cb(updateRank(src))
end)

QBCore.Functions.CreateCallback("hiype-cardelivery:server-metadata-available", function(source, cb)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local metadata = Player.PlayerData.metadata[metaDataName]
	if metadata then
		cb(true)
	else
		cb(false)
	end
end)

QBCore.Functions.CreateCallback('hiype-cardelivery:server-get-start-ped', function(source, cb)
	cb(startPed)
end)

QBCore.Functions.CreateCallback('hiype-cardelivery:server-get-net-start-ped', function(source, cb)
	cb(netStartPed)
end)

QBCore.Commands.Add(Lang:t('commands.edit_call'), Lang:t('commands.edit_description'), {
	{
		name = Lang:t('commands.edit_option_name'),
		help = Lang:t('commands.edit_option_help')
	},
	{
		name = Lang:t('commands.edit_number_name'),
		help = Lang:t('commands.edit_number_help')
	}
}, true, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local metadata = Player.PlayerData.metadata[metaDataName]
	if args[1] and args[2] then
		if args[1] == Lang:t('commands.edit_add') then
			changeMetaData(src, tonumber(args[2]))
			TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, updateRank(src))
		elseif args[1] == Lang:t('commands.edit_set') then
			setMetaData(src, tonumber(args[2]))
			TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, updateRank(src))
		elseif args[1] == Lang:t('commands.edit_reduce') then
			changeMetaData(src, tonumber(args[2]) * -1)
			TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, updateRank(src))
		else
			TriggerClientEvent("QBCore:Notify", src, Lang:t('commands.no_such_parameter'), "error")
		end
	else
		TriggerClientEvent("QBCore:Notify", src, Lang:t('commands.not_enough_parameters'), "error")
	end
end, Config.PermissionLevel)

QBCore.Commands.Add(Lang:t('commands.status_call'), Lang:t('commands.status_description'), {}, true, function(source, args)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	local metadata = Player.PlayerData.metadata[metaDataName]
	local rank = updateRank(src)
    TriggerClientEvent("QBCore:Notify", src, string.format(Lang:t('info.rank') .. " (%i)", rank, metadata), "primary")
	TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, updateRank(src))
end)

function updateRank(src)
    local rank = 1
    local rankGoals = Config.XpGoals
    local Player = QBCore.Functions.GetPlayer(src)
	
	local timeout = 5000
	while not Player and timeout > 0 do
		Wait(200)
		timeout = timeout - 200
		Player = QBCore.Functions.GetPlayer(src)
	end

	if not Player then print("Getting player data timed out") end

	local metadata = Player.PlayerData.metadata[metaDataName]

	if metadata ~= nil then
		for i=1, #rankGoals, 1 do
			if metadata >= rankGoals[i] then
				rank = i + 1
			end
		end
        return rank
    else
        TriggerClientEvent("QBCore:Notify", src, "Metadata was nil", "error")
        return nil
    end
end

function setMetaData(src, newValue)
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
		Player.Functions.SetMetaData(metaDataName, newValue)
		TriggerClientEvent("hiype-cardelivery:client-receive-rank", src, updateRank(src))
	end
end

function changeMetaData(src, change)
    local Player = QBCore.Functions.GetPlayer(src)
	local metadata = Player.PlayerData.metadata[metaDataName]

    if metadata + change < 0 then
		change = metadata * (-1)
	end
    setMetaData(src, metadata + change)
end