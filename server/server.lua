local cachePlayers = {}
local Server = {
    RefundPrice = 150,
    Rentals = {
        trailersmall = {price = 250, spawn = vec4(-48.56, -1692.29, 30, 280)},
        boattrailer = {price = 250, spawn = vec4(-57.40, -1685.42, 29.49, 300)},
    },
}

local function createTrailer(source, model, coords)
    local veh = CreateVehicle(joaat(model), coords.x, coords.y, coords.z, coords.w, true, true)
    local ped = GetPlayerPed(source)

    while not DoesEntityExist(veh) do Wait(0) end 

    return veh
end

lib.callback.register('az_trailer:server:attemptRental', function(source, model)
    if cachePlayers[source] then
        QBCore.Functions.Notify(source, 'You already have a rental.', 'error')
        return false 
    end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local balance = Player.PlayerData.money.cash
    if Server.Rentals[model] and balance >= Server.Rentals[model].price then
        Player.Functions.RemoveMoney('cash', Server.Rentals[model].price, 'Trailer Rental')
        local coords = Server.Rentals[model].spawn or vec4(-49.96, -1692.76, 29.49, 287.79)
        local vehicle = createTrailer(src, model, coords)
        cachePlayers[src] = {}
        cachePlayers[src].entity = vehicle
        return true, NetworkGetNetworkIdFromEntity(vehicle)
    else
        QBCore.Functions.Notify(source, ('You need $%s in cash to rent this trailer'):format(Server.Rentals[model].price), 'error')
        return false
    end
end)

lib.callback.register('az_trailer:server:returnRental', function(source)
    if not cachePlayers[source] then return false end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if cachePlayers[src].entity and DoesEntityExist(cachePlayers[src].entity) then
        DeleteEntity(cachePlayers[src].entity)
        Player.Functions.AddMoney('cash', Server.RefundPrice, 'Returned Trailer')
        QBCore.Functions.Notify(source, ('You received $%s for returning the trailer.'):format(Server.RefundPrice))
    else
        QBCore.Functions.Notify(source, 'Your trailer could not be found and returned. You were not refunded.', 'error')
    end

    cachePlayers[src] = nil
    return true
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        SetTimeout(2000, function()
            TriggerClientEvent('az_trailer:cacheConfig', -1, Server)
        end)
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    SetTimeout(2000, function()
        TriggerClientEvent('az_trailer:cacheConfig', source, Server)
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    local src = source
    if cachePlayers[src] then
        if cachePlayers[src].entity and DoesEntityExist(cachePlayers[src].entity) then
            DeleteEntity(cachePlayers[src].entity)
        end
        cachePlayers[src] = nil
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if cachePlayers[src] then
        if cachePlayers[src].entity and DoesEntityExist(cachePlayers[src].entity) then
            DeleteEntity(cachePlayers[src].entity)
        end
        cachePlayers[src] = nil
    end
end)