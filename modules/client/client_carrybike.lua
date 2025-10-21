local bikes = Config.Bikes
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

CreateThread(function()
    for _, model in pairs(Config.Bikes) do
        exports.ox_target:addModel(model, {
            {
                name = 'plukkopp_sykkel',
                label = 'Pick up Bicycle',
                icon = 'fa-solid fa-bicycle',
                event = 'hbd:carrybike',
                distance = 2.0,
            }
        })
    end
end)

RegisterNetEvent('hbd:carrybike', function()
    local ped = cache.ped
    local coords = GetEntityCoords(cache.ped)
    local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

    if not vehicle or vehicle == 0 then
        return exports.lation_ui:notify({
            title = 'Bike Carrying',
            description = 'No bike nearby!',
            type = 'error'
        })
    end

    if not BikeCheck(vehicle) then
        return exports.lation_ui:notify({
            title = 'Bike Carrying',
            description = 'You can\n't pick up this bike.',
            type = 'error'
        })
    end

    local bone = 24818
    AttachEntityToEntity(vehicle, ped, bone, 0.18, -0.20, 0.40, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    carriedBike = vehicle
    carryingBike = true
    carryThreadActive = true

    exports.lation_ui:notify({
        title = 'Bike Carrying',
        description = 'Press [G] to release the bike.',
        type = 'error'
    })

    RequestAnimDict("move_p_m_zero_rucksack")
    while not HasAnimDictLoaded("move_p_m_zero_rucksack") do Wait(0) end
    TaskPlayAnim(ped, "move_p_m_zero_rucksack", "idle", 2.0, 2.0, -1, 51, 0, false, false, false)

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
