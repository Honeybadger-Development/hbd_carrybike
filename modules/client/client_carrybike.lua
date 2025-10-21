local bikes = Config.BikeModels
local carryingBike = false
local carriedBike = nil
local carryThreadActive = false

function BikeCheck(bike)
    local model = GetEntityModel(bike)
    for _, v in pairs(bikes) do
        if v == model then
            return true
        end
    end
    return false
end


CreateThread(function()

-- // Ikke sikker om dette er reelt for øyeblikket.
-- while not lib or not lib.addKeybind do Wait(100) end

    lib.addKeybind({
        name = 'slipp_sykkel',
        description = 'Slipp Sykkel',
        defaultKey = 'G',
        onPressed = function()
            if carryingBike and carriedBike and DoesEntityExist(carriedBike) and IsEntityAttached(carriedBike) then
                local ped = cache.ped
                DetachEntity(carriedBike, true, true)
                SetVehicleOnGroundProperly(carriedBike)
                ClearPedTasksImmediately(ped)
                carryingBike = false
                carriedBike = nil
                carryThreadActive = false

                exports.lation_ui:notify({
                    title = 'Sykkel',
                    description = 'Du slapp sykkelen.',
                    type = 'inform'
                })
            end
        end
    })

end)

RegisterNetEvent('hbd:carrybike', function()
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

    if not vehicle or vehicle == 0 then
        return exports.lation_ui:notify({
            title = 'Feil',
            description = 'Ingen sykkel i nærheten!',
            type = 'error'
        })
    end

    if not BikeCheck(vehicle) then
        return exports.lation_ui:notify({
            title = 'Feil',
            description = 'Du kan ikke plukke opp denne sykkelen!', -- Legg til i shared/config.lua
            type = 'error'
        })
    end

    -- Attach bike
    local bone = 24818
    AttachEntityToEntity(vehicle, ped, bone, 0.18, -0.20, 0.40, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    carriedBike = vehicle
    carryingBike = true
    carryThreadActive = true

    exports.lation_ui:notify({
        title = 'Bæring av sykkel',
        description = 'Trykk [G] for å slippe sykkelen.',
        type = 'error'
    })

    -- Play carry animation
    RequestAnimDict("move_p_m_zero_rucksack")
    while not HasAnimDictLoaded("move_p_m_zero_rucksack") do Wait(0) end
    TaskPlayAnim(ped, "move_p_m_zero_rucksack", "idle", 2.0, 2.0, -1, 51, 0, false, false, false)

    -- Carry loop
    CreateThread(function()
        while carryThreadActive do
            Wait(1000)

            if not DoesEntityExist(ped) or not DoesEntityExist(carriedBike) then
                carryingBike = false
                carriedBike = nil
                carryThreadActive = false
                break
            end

            if not IsEntityPlayingAnim(ped, "move_p_m_zero_rucksack", "idle", 3) then
                TaskPlayAnim(ped, "move_p_m_zero_rucksack", "idle", 2.0, 2.0, -1, 51, 0, false, false, false)
            end

            if not IsEntityAttachedToEntity(carriedBike, ped) then
                carryingBike = false
                carriedBike = nil
                carryThreadActive = false
                ClearPedTasksImmediately(ped)
            end
        end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        carryThreadActive = false
        local ped = cache.ped

        if carryingBike and carriedBike and DoesEntityExist(carriedBike) then
            DetachEntity(carriedBike, true, true)
            SetVehicleOnGroundProperly(carriedBike)
        end

        carryingBike = false
        carriedBike = nil
        ClearPedTasksImmediately(ped)
    end
end)
