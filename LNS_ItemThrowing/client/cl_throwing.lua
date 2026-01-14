local Settings = lib.load('shared.settings')
local throwingItem, givingItem = false, false
local attachedProp, previewProp = nil, nil
local currentThrowData, currentGiveData = {}, {}
local initializingThrow = false

local function MakeItemThrowable(itemName, propModel, slot)
    if throwingItem or givingItem then return end
    
    initializingThrow = true
    local ped = cache.ped
    local inVehicle = IsPedInAnyVehicle(ped, false)

    GiveWeaponToPed(ped, `WEAPON_SNOWBALL`, 1, false, true)
    SetCurrentPedWeapon(ped, `WEAPON_SNOWBALL`, true)
    SetPedCurrentWeaponVisible(ped, false, false, false, false)

    CreateThread(function()
        while throwingItem do
            SetPedCurrentWeaponVisible(ped, false, false, false, false)
            local snowball = GetClosestObjectOfType(GetEntityCoords(ped), 10.0, `w_snowball`, false, false, false)
            if DoesEntityExist(snowball) then
                SetEntityVisible(snowball, false, false)
                SetEntityCollision(snowball, false, false)
            end
            Wait(0)
        end
    end)

    lib.requestModel(propModel, 5000)

    if not inVehicle then
        local bone = GetPedBoneIndex(ped, 28422)
        attachedProp = CreateObject(propModel, 0, 0, 0, true, true, true)
        AttachEntityToEntity(attachedProp, ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
    
    throwingItem = true
    currentThrowData = {itemName = itemName, propModel = propModel, slot = slot}

    lib.showTextUI('[X] Cancel Throw', {icon = 'hand'})

    CreateThread(function()
        for i = 1, 10 do
            Wait(50)
            if not HasPedGotWeapon(ped, `WEAPON_SNOWBALL`, false) then
                GiveWeaponToPed(ped, `WEAPON_SNOWBALL`, 1, false, true)
            end
            SetCurrentPedWeapon(ped, `WEAPON_SNOWBALL`, true)
            SetPedInfiniteAmmoClip(ped, true)
        end
        
        initializingThrow = false

        while throwingItem do
            Wait(0)

            if not HasPedGotWeapon(ped, `WEAPON_SNOWBALL`, false) then
                GiveWeaponToPed(ped, `WEAPON_SNOWBALL`, 1, false, true)
                SetCurrentPedWeapon(ped, `WEAPON_SNOWBALL`, true)
            end
            
            SetPedInfiniteAmmoClip(ped, true)

            if IsControlJustPressed(0, 73) then
                if DoesEntityExist(attachedProp) then
                    DeleteEntity(attachedProp)
                    attachedProp = nil
                end
                RemoveWeaponFromPed(ped, `WEAPON_SNOWBALL`)
                throwingItem = false
                initializingThrow = false
                currentThrowData = {}
                lib.hideTextUI()
                lib.notify({description = 'Throw cancelled', type = 'inform'})
                break
            end

            if IsPedShooting(ped) then
                local projectile = GetClosestObjectOfType(GetEntityCoords(ped), 5.0, `w_snowball`, false, false, false)
                if DoesEntityExist(projectile) then
                    SetEntityVisible(projectile, false, false)
                    DeleteEntity(projectile)
                end
                
                local camRot = GetGameplayCamRot(0)
                local pedCoords = GetEntityCoords(ped)
                local throwCoord

                if IsPedInAnyVehicle(ped, false) then
                    local veh = cache.vehicle
                    local vehCoords = GetEntityCoords(veh)
                    local forward = GetEntityForwardVector(veh)
                    throwCoord = vehCoords + (forward * 2.0) + vec3(0, 0, 0.5)
                else
                    throwCoord = pedCoords + vec3(0, 0, 1.0)
                end

                if DoesEntityExist(attachedProp) then
                    DeleteEntity(attachedProp)
                    attachedProp = nil
                end

                local flyingProp = CreateObject(propModel, throwCoord.x, throwCoord.y, throwCoord.z, true, true, true)
                NetworkRegisterEntityAsNetworked(flyingProp)
                SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(flyingProp), true)
                SetEntityAsMissionEntity(flyingProp, true, true)

                local force = Settings.ThrowForce
                local radRot = vec3(math.rad(camRot.x), math.rad(camRot.y), math.rad(camRot.z))
                local forceVec = vec3(-math.sin(radRot.z) * math.abs(math.cos(radRot.x)) * force, math.cos(radRot.z) * math.abs(math.cos(radRot.x)) * force, math.sin(radRot.x) * force)

                if IsPedInAnyVehicle(ped, false) then
                    local veh = cache.vehicle
                    local vehVel = GetEntityVelocity(veh)
                    forceVec = forceVec + (vehVel * 0.5)
                end
                
                ApplyForceToEntity(flyingProp, 1, forceVec.x, forceVec.y, forceVec.z, 0.0, 0.0, 0.0, 0, false, true, true, false, true)

                local netId = NetworkGetNetworkIdFromEntity(flyingProp)
                local throwData = {
                    itemName = currentThrowData.itemName,
                    slot = currentThrowData.slot
                }

                CreateThread(function()
                    local landed = false
                    local lastZ = GetEntityCoords(flyingProp).z
                    local stableFrames = 0

                    while not landed and DoesEntityExist(flyingProp) do
                        Wait(100)

                        local coords = GetEntityCoords(flyingProp)
                        local vel = GetEntityVelocity(flyingProp)
                        local speed = #vel

                        if speed < 0.5 and math.abs(coords.z - lastZ) < 0.1 then
                            stableFrames = stableFrames + 1
                            if stableFrames >= 3 then landed = true end
                        else
                            stableFrames = 0
                        end

                        lastZ = coords.z
                    end

                    if landed and DoesEntityExist(flyingProp) then
                        local finalCoords = GetEntityCoords(flyingProp)
                        FreezeEntityPosition(flyingProp, true)
                        SetEntityCollision(flyingProp, true, true)

                        local success = lib.callback.await('LNS_ItemThrowing:createProp', false, {
                            coords = finalCoords,
                            itemName = throwData.itemName,
                            slot = throwData.slot,
                            netId = netId
                        })

                        if not success and DoesEntityExist(flyingProp) then
                            DeleteEntity(flyingProp)
                            lib.notify({description = 'Failed to throw item', type = 'error'})
                        end
                    end
                end)

                RemoveWeaponFromPed(ped, `WEAPON_SNOWBALL`)
                throwingItem = false
                initializingThrow = false
                currentThrowData = {}
                lib.hideTextUI()
                break
            end
        end
    end)
end

local function StartGiveMode(itemName, slot, count)
    if givingItem or throwingItem then return end
    
    local propModel = Settings.ItemModels[itemName]
    if not propModel then
        local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), Settings.MaxGiveDistance)
        if #nearbyPlayers == 0 then
            return lib.notify({description = 'No nearby players', type = 'error'})
        end
        
        local targetPlayer = nearbyPlayers[1]
        local targetId = GetPlayerServerId(targetPlayer.id)
        exports.ox_inventory:giveItemToTarget(targetId, slot, count)
        return
    end
    
    givingItem = true
    currentGiveData = {itemName = itemName, slot = slot, count = count, propModel = propModel}
    
    lib.requestModel(propModel, 5000)
    
    previewProp = CreateObject(propModel, 0, 0, 0, false, false, false)
    SetEntityCollision(previewProp, false, false)
    SetEntityAlpha(previewProp, 200, false)
    SetEntityCompletelyDisableCollision(previewProp, false, false)
    
    local propRotation = 0.0
    
    lib.showTextUI('[E] Place Item | [G] Throw Item | [SCROLL] Rotate | [X] Cancel', {
        position = 'bottom-center',
        icon = 'hand-holding'
    })
    
    CreateThread(function()
        local ped = cache.ped
        local lastHit, wasPlayer = nil, false
        
        while givingItem do
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)

            if IsDisabledControlPressed(0, 14) then
                propRotation = (propRotation - 2.0) % 360
            elseif IsDisabledControlPressed(0, 15) then
                propRotation = (propRotation + 2.0) % 360
            end

            local camCoords = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(0)
            local radRot = vec3(math.rad(camRot.x), math.rad(camRot.y), math.rad(camRot.z))
            local dir = vec3(-math.sin(radRot.z) * math.abs(math.cos(radRot.x)), math.cos(radRot.z) * math.abs(math.cos(radRot.x)), math.sin(radRot.x))
            local endCoords = camCoords + (dir * 10.0)
            local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, endCoords.x, endCoords.y, endCoords.z, -1, ped, 0)
            local _, hit, coords, _, hitEntity = GetShapeTestResult(ray)
            
            if hit then
                SetEntityCoords(previewProp, coords.x, coords.y, coords.z, false, false, false, false)
                SetEntityRotation(previewProp, 0.0, 0.0, propRotation, 2, true)

                local isPlayer = false
                if DoesEntityExist(hitEntity) then
                    if hitEntity ~= lastHit then
                        isPlayer = IsPedAPlayer(hitEntity)
                        wasPlayer = isPlayer
                        lastHit = hitEntity
                        SetEntityAlpha(previewProp, isPlayer and 255 or 150, false)
                    else
                        isPlayer = wasPlayer
                    end
                else
                    if lastHit then
                        SetEntityAlpha(previewProp, 150, false)
                        lastHit = nil
                        wasPlayer = false
                    end
                end

                if IsControlJustPressed(0, 38) then
                    if isPlayer then
                        local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(hitEntity))
                        local dist = #(GetEntityCoords(ped) - GetEntityCoords(hitEntity))
                        
                        if dist <= Settings.MaxGiveDistance then
                            exports.ox_inventory:giveItemToTarget(targetId, currentGiveData.slot, currentGiveData.count)
                            if DoesEntityExist(previewProp) then DeleteEntity(previewProp) end
                            givingItem = false
                            currentGiveData = {}
                            lib.hideTextUI()
                            break
                        else
                            lib.notify({description = 'Too far from player', type = 'error'})
                        end
                    else
                        local success = lib.callback.await('LNS_ItemThrowing:placeItem', false, {
                            coords = coords,
                            rotation = vec3(0.0, 0.0, propRotation),
                            itemName = currentGiveData.itemName,
                            slot = currentGiveData.slot,
                            propModel = currentGiveData.propModel
                        })

                        if success then
                            if DoesEntityExist(previewProp) then DeleteEntity(previewProp) end
                            givingItem = false
                            currentGiveData = {}
                            lib.hideTextUI()
                            lib.notify({description = 'Item placed', type = 'success'})
                        else
                            lib.notify({description = 'Failed to place item', type = 'error'})
                        end
                        break
                    end
                end

                if IsControlJustPressed(0, 47) then
                    if DoesEntityExist(previewProp) then DeleteEntity(previewProp) end
                    lib.hideTextUI()
                    
                    local giveData = currentGiveData
                    currentGiveData = {}
                    givingItem = false
                    Wait(250)
                    
                    MakeItemThrowable(giveData.itemName, giveData.propModel, giveData.slot)
                    break
                end
            else
                local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
                SetEntityCoords(previewProp, offset.x, offset.y, offset.z, false, false, false, false)
                SetEntityRotation(previewProp, 0.0, 0.0, propRotation, 2, true)
                
                if lastHit then
                    lastHit = nil
                    wasPlayer = false
                end
            end

            if IsControlJustPressed(0, 73) then
                if DoesEntityExist(previewProp) then DeleteEntity(previewProp) end
                givingItem = false
                currentGiveData = {}
                lib.hideTextUI()
                lib.notify({description = 'Give cancelled', type = 'inform'})
                break
            end
            
            Wait(0)
        end
    end)
end

exports('throwItem', function(data)
    local itemName, slot
    
    if type(data) == 'number' then
        slot = data
        local inv = exports.ox_inventory:GetPlayerItems()
        if inv and inv[slot] then
            itemName = inv[slot].name
        end
    elseif type(data) == 'table' and data.name then
        itemName = data.name
        slot = data.slot
    end
    
    if not itemName then
        return lib.notify({description = 'Invalid item data', type = 'error'})
    end
    
    local propModel = Settings.ItemModels[itemName]
    if not propModel then
        return lib.notify({description = 'This item cannot be thrown', type = 'error'})
    end
    
    MakeItemThrowable(itemName, propModel, slot)
end)

exports('startGiveMode', function(itemName, slot, count)
    StartGiveMode(itemName, slot, count)
end)

RegisterNetEvent('LNS_ItemThrowing:registerTarget', function(propId, netId)
    CreateThread(function()
        local entity
        local timeout = GetGameTimer() + 5000

        repeat
            entity = NetworkGetEntityFromNetworkId(netId)
            Wait(100)
        until DoesEntityExist(entity) or GetGameTimer() > timeout

        if not DoesEntityExist(entity) then return end

        exports.ox_target:addLocalEntity(entity, {
            {
                name = 'pickup_thrown_item',
                icon = 'fas fa-hand-paper',
                label = 'Pick Up Item',
                distance = 2.0,
                onSelect = function()
                    local success = lib.callback.await('LNS_ItemThrowing:pickupItem', false, propId)
                    if not success then
                        lib.notify({description = 'Failed to pickup item', type = 'error'})
                    end
                end
            }
        })
    end)
end)

RegisterNetEvent('LNS_ItemThrowing:createPlacedProp', function(data)
    CreateThread(function()
        lib.requestModel(data.propModel, 5000)

        local prop = CreateObject(data.propModel, data.coords.x, data.coords.y, data.coords.z, true, true, true)

        if data.rotation then
            SetEntityRotation(prop, data.rotation.x, data.rotation.y, data.rotation.z, 2, true)
        end

        FreezeEntityPosition(prop, true)
        SetEntityCollision(prop, true, true)
        
        NetworkRegisterEntityAsNetworked(prop)
        local netId = NetworkGetNetworkIdFromEntity(prop)

        TriggerServerEvent('LNS_ItemThrowing:updatePlacedPropNetId', data.propId, netId)
        TriggerServerEvent('LNS_ItemThrowing:broadcastPlacedProp', data.propId, netId)
    end)
end)

RegisterNetEvent('LNS_ItemThrowing:removeProp', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        exports.ox_target:removeLocalEntity(entity)
        DeleteEntity(entity)
    end
end)