local Config = lib.require('config')
local notfindtrailer = true

local blip = AddBlipForCoord(Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z)
SetBlipSprite (blip, Config.BlipSprite)
SetBlipDisplay(blip, 2)
SetBlipScale  (blip, Config.BlipScale)
SetBlipColour (blip, Config.BlipColour)
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString(Config.BlipName)
EndTextCommandSetBlipName(blip)

CreateThread(function()
    CreateNPC()
end)

local globalSearch = function()
    return GetVehicleInDirection(GetEntityCoords(cache.ped), GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 20.0, 0.0))
end

CreateNPC = function()
    RequestModel(joaat(Config.PedModel)) while not HasModelLoaded(joaat(Config.PedModel)) do Wait(0) end
    created_ped = CreatePed(5, joaat(Config.PedModel) , Config.PedLocation.x, Config.PedLocation.y, Config.PedLocation.z, Config.PedLocation.w, false, true)
    FreezeEntityPosition(created_ped, true)
    SetEntityInvincible(created_ped, true)
    SetBlockingOfNonTemporaryEvents(created_ped, true)
    TaskStartScenarioInPlace(created_ped, Config.PedScenario, 0, true)
    exports['qb-target']:AddTargetEntity(created_ped, {
        options = {
            {
                icon = 'fa-solid fa-circle',
                label = 'Trailers',
                action = function(entity)
                    TriggerEvent('az-trailer:openMenu')
                end,
            },
        },
        distance = 1.5,
    })
end

function GetVehicleInDirection(cFrom, cTo)
    trailerfind = nil
    notfindtrailer = true
    local rayHandle = CastRayPointToPoint(cFrom.x, cFrom.y, cFrom.z, cTo.x, cTo.y, cTo.z, 10, cache.ped, 0)
    local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
    if vehicle == 0 then
        notfindtrailer = true
    else
        notfindtrailer = false
        trailerfind = vehicle
    end
    return trailerfind
end

AddEventHandler('az-trailer:return', function()
    local success = lib.callback.await('az_trailer:server:returnRental', false)
    if not success then
        QBCore.Functions.Notify('You do not have a current rental out.', 'error')
    end
end)

AddEventHandler('az-trailer:spawncar', function(model)
    local success = lib.callback.await('az_trailer:server:attemptRental', false, model)
    if not success then
        QBCore.Functions.Notify('You do not have a current rental out.', 'error')
    end
end)

AddEventHandler('az-trailer:openMenu', function()
    if Config.Menu == 'ox' then
        lib.registerContext({
            id = 'rental_trailers',
            title = 'Rental Trailers',
            options = {
              {
                title = 'Return Trailer',
                description = 'Return your rented trailer',
                event = 'az-trailer:return',
              },
              {
                title = 'Rent Car Trailer',
                description = ('$%s deposit'):format(Config.TrailersmallPrice),
                onSelect = function()
                    TriggerEvent('az-trailer:spawncar', 'trailersmall')
                end,
              },
              {
                title = 'Rent Boat Trailer',
                description = ('$%s deposit'):format(Config.BoattrailerPrice),
                onSelect = function()
                    TriggerEvent('az-trailer:spawncar', 'boattrailer')
                end,
              },
            },
          })
        lib.showContext('rental_trailers')
    else
        exports['qb-menu']:openMenu({
            {
                header = 'Rental Trailers',
                isMenuHeader = true,
            },
            {
                id = 1,
                header = 'Return Trailer',
                txt = 'Return your rented trailer',
                params = {
                    event = 'az-trailer:return',
                }
            },
            {
                id = 2,
                header = 'Rent Car Trailer',
                txt = ('$%s deposit'):format(Config.TrailersmallPrice),
                params = {
                    event = 'az-trailer:spawncar',
                    args = 'trailersmall',
                }
            },
            {
                id = 3,
                header = 'Rent Boat Trailer',
                txt = ('$%s deposit'):format(Config.BoattrailerPrice),
                params = {
                    event = 'az-trailer:spawncar',
                    args = 'boattrailer',
                }
            },
        })
    end
end)

spawnramp = false
RegisterCommand('setramp', function()
    if not spawnramp then
        spawnramp = true
        local ped = cache.ped
        local coordA = GetEntityCoords(cache.ped, 1)
        local coordB = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 20.0, 0.0)
        local trailerfind = GetVehicleInDirection(coordA, coordB)
        if tonumber(trailerfind) ~= 0 and trailerfind ~= nil then
            local playercoords = GetEntityCoords(cache.ped)
            ramp = CreateObject(GetHashKey('prop_water_ramp_02'), playercoords.x, playercoords.y, playercoords.z - 1.4, false, false, false)
            SetEntityHeading(ramp, GetEntityHeading(cache.ped))
            trailerfind = nil
            notfindtrailer = true
        else
            spawnramp = false
            QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
        end
    else
        QBCore.Functions.Notify(Config.Lang["RampAlreadySet"], 'warning')
    end
end, false)

RegisterCommand('deleteramp', function()
    if spawnramp then
        DeleteEntity(ramp)
        spawnramp = false
    end
end, false)

local CommandTable = {
    ["attachtrailer"] = function()
        local veh = GetVehiclePedIsIn(cache.ped)
        local havetobreak = false
        if veh ~= nil and veh ~= 0 then
            local belowFaxMachine = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, -1.0)
            local boatCoordsInWorldLol = GetEntityCoords(veh)
            havefindclass = false
            testnb = 0.0
            while notfindtrailer do
                local trailerfind = GetVehicleInDirection(vector3(boatCoordsInWorldLol.x, boatCoordsInWorldLol.y, boatCoordsInWorldLol.z), vector3(belowFaxMachine.x, belowFaxMachine.y, belowFaxMachine.z - testnb))
                testnb = testnb + 0.1
                if not startdecompte then
                    startdecompte = true
                    Citizen.SetTimeout(5000, function()
                        if trailerfind ~= 0 and trailerfind ~= nil then
                            startdecompte = false
                            QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
                            havetobreak = true
                        end
                    end)
                end
                if havetobreak then
                    break
                end
                Citizen.Wait(0)
            end
            if tonumber(trailerfind) ~= 0 and trailerfind ~= nil then
                for k, v in pairs(Config.VehicleCanTrail) do
                    if v.name == GetDisplayNameFromVehicleModel(GetEntityModel(trailerfind)) then
                        for x, w in pairs(v.class) do
                            if w == GetVehicleClass(veh) then
                                havefindclass = true
                            end
                        end
                        if havefindclass then
                            AttachEntityToEntity(veh, trailerfind, GetEntityBoneIndexByName(trailerfind, 'chassis'), GetOffsetFromEntityGivenWorldCoords(trailerfind, boatCoordsInWorldLol), 0.0, 0.0, 0.0, false, false, true, false, 20, true)
                            TaskLeaveVehicle(cache.ped, veh, 64)
                        else
                            QBCore.Functions.Notify(Config.Lang["CantSetThisType"], 'error')
                        end
                    end
                end
                trailerfind = nil
                notfindtrailer = true
            else
                QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
            end
        else
            QBCore.Functions.Notify(Config.Lang["NotInVehicle"], 'error')
        end
    end,
    ["detachtrailer"] = function()
        if IsPedInAnyVehicle(cache.ped, true) then
            local veh = GetVehiclePedIsIn(cache.ped)
            if DoesEntityExist(veh) and IsEntityAttached(veh) then
                DetachEntity(veh, true, true)
                notfindtrailer = true
                trailerfind = nil
            else
                QBCore.Functions.Notify(Config.Lang["NoVehicleSet"], 'error')
            end
        else
            local vehicleintrailer = globalSearch()
            if tonumber(vehicleintrailer) ~= 0 and vehicleintrailer ~= nil and IsEntityAttached(vehicleintrailer) then
                DetachEntity(vehicleintrailer, true, true)
                notfindtrailer = true
                trailerfind = nil
            else
                QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
            end
        end
    end,
    ["openramptr2"] = function()
        local trailerfind = globalSearch()
        if tonumber(trailerfind) ~= 0 and trailerfind ~= nil then
            if GetDisplayNameFromVehicleModel(GetEntityModel(trailerfind)) == 'TRAILER' then
                SetVehicleDoorOpen(trailerfind, 4, false, false)
            end
            trailerfind = nil
            notfindtrailer = true
        else
            QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
        end
    end,
    ["closeramptr2"] = function()
        local trailerfind = globalSearch()
        if tonumber(trailerfind) ~= 0 and trailerfind ~= nil then
            if GetDisplayNameFromVehicleModel(GetEntityModel(trailerfind)) == 'TRAILER' then
                SetVehicleDoorShut(trailerfind, 4, false, false)
            end
            trailerfind = nil
            notfindtrailer = true
        else
            QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
        end
    end,
    ["opentrunktr2"] = function()
        local trailerfind = globalSearch()
        if tonumber(trailerfind) ~= 0 and trailerfind ~= nil then
            if GetDisplayNameFromVehicleModel(GetEntityModel(trailerfind)) == 'TRAILER' then
                SetVehicleDoorOpen(trailerfind, 5, false, false)
            end
            trailerfind = nil
            notfindtrailer = true
        else
            QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
        end
    end,
    ["closetrunktr2"] = function()
        local trailerfind = globalSearch()
        if tonumber(trailerfind) ~= 0 and trailerfind ~= nil then
            if GetDisplayNameFromVehicleModel(GetEntityModel(trailerfind)) == 'TRAILER' then
                SetVehicleDoorShut(trailerfind, 5, false, false)
            end
            trailerfind = nil
            notfindtrailer = true
        else
            QBCore.Functions.Notify(Config.Lang["TrailerNotFound"], 'error')
        end
    end,
}

for k, v in pairs(Config.Command) do
    RegisterCommand(v, function()
        CommandTable[k]()
    end)
end

RegisterNetEvent('az_trailer:cacheConfig', function(data)
    if GetInvokingResource() or not LocalPlayer.state.isLoggedIn then return end
    Config.RefundPrice = data.RefundPrice
    Config.TrailersmallPrice = data.Rentals['trailersmall'].price
    Config.BoattrailerPrice = data.Rentals['boattrailer'].price
end)