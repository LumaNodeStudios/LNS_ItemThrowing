local Settings = lib.load('shared.settings')
local activeProps = {}
local cooldowns = {}

local function onCooldown(src)
    local last = cooldowns[src]
    return last and (GetGameTimer() - last) < Settings.CooldownTime
end

local function destroyProp(propId)
    local prop = activeProps[propId]
    if not prop then return end
    TriggerClientEvent('LNS_ItemThrowing:removeProp', -1, prop.netId)
    activeProps[propId] = nil
end

lib.callback.register('LNS_ItemThrowing:createProp', function(source, data)
    if not data or not data.itemName or not data.coords or not data.slot or not data.netId then 
        return false
    end
    
    if onCooldown(source) then
        lib.notify(source, {type = 'error', description = 'Please wait before throwing again'})
        return false
    end
    
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - data.coords) > Settings.MaxThrowDistance then
        lib.notify(source, {type = 'error', description = 'Invalid throw distance'})
        return false
    end

    if not Settings.ItemModels[data.itemName] then
        lib.notify(source, {type = 'error', description = 'This item cannot be thrown'})
        return false
    end
    
    local removed = exports.ox_inventory:RemoveItem(source, data.itemName, 1, nil, data.slot)
    if not removed then
        lib.notify(source, {type = 'error', description = 'Failed to throw item'})
        return false
    end
    
    cooldowns[source] = GetGameTimer()
    
    local propId = ('thrown_%d_%d'):format(math.random(100000, 999999), os.time())
    activeProps[propId] = {
        netId = data.netId,
        itemName = data.itemName,
        coords = data.coords
    }
    
    TriggerClientEvent('LNS_ItemThrowing:registerTarget', -1, propId, data.netId)

    SetTimeout(Settings.PropLifetime, function()
        destroyProp(propId)
    end)
    
    return true, propId
end)

lib.callback.register('LNS_ItemThrowing:placeItem', function(source, data)
    if not data or not data.itemName or not data.coords or not data.slot or not data.propModel then 
        return false
    end
    
    if onCooldown(source) then
        lib.notify(source, {type = 'error', description = 'Please wait before placing again'})
        return false
    end
    
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - data.coords) > Settings.MaxPlaceDistance then
        lib.notify(source, {type = 'error', description = 'Invalid placement distance'})
        return false
    end

    if Settings.ItemModels[data.itemName] ~= data.propModel then
        lib.notify(source, {type = 'error', description = 'Invalid item model'})
        return false
    end
    
    local removed = exports.ox_inventory:RemoveItem(source, data.itemName, 1, nil, data.slot)
    if not removed then
        lib.notify(source, {type = 'error', description = 'Failed to place item'})
        return false
    end
    
    cooldowns[source] = GetGameTimer()
    
    local propId = ('placed_%d_%d'):format(math.random(100000, 999999), os.time())
    
    TriggerClientEvent('LNS_ItemThrowing:createPlacedProp', source, {
        propId = propId,
        coords = data.coords,
        rotation = data.rotation,
        itemName = data.itemName,
        propModel = data.propModel
    })
    
    activeProps[propId] = {
        netId = nil,
        itemName = data.itemName,
        coords = data.coords
    }
    
    SetTimeout(Settings.PropLifetime, function()
        destroyProp(propId)
    end)
    
    return true, propId
end)

lib.callback.register('LNS_ItemThrowing:pickupItem', function(source, propId)
    local prop = activeProps[propId]
    
    if not prop then
        lib.notify(source, {type = 'error', description = 'Item no longer available'})
        return false
    end
    
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - prop.coords) > Settings.PickupDistance then
        lib.notify(source, {type = 'error', description = 'Too far from item'})
        return false
    end
    
    local added = exports.ox_inventory:AddItem(source, prop.itemName, 1)
    
    if added then
        lib.notify(source, {type = 'success', description = 'Item picked up'})
        destroyProp(propId)
        return true
    else
        lib.notify(source, {type = 'error', description = 'Inventory full'})
        return false
    end
end)

RegisterNetEvent('LNS_ItemThrowing:updatePlacedPropNetId', function(propId, netId)
    if activeProps[propId] then
        activeProps[propId].netId = netId
    end
end)

RegisterNetEvent('LNS_ItemThrowing:broadcastPlacedProp', function(propId, netId)
    TriggerClientEvent('LNS_ItemThrowing:registerTarget', -1, propId, netId)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    
    for propId in pairs(activeProps) do
        destroyProp(propId)
    end
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

CreateThread(function()
    local resource = GetCurrentResourceName()
    local currentVersion = GetResourceMetadata(resource, 'version', 0) or '1.0.0'
    
    PerformHttpRequest('https://raw.githubusercontent.com/LumaNodeStudios/LNS_ItemThrowing/main/fxmanifest.lua', function(status, response, headers)
        if status ~= 200 then
            print('^3[' .. resource .. '] ^7Unable to check for updates (Status: ' .. status .. ')^0')
            return
        end
        
        local latestVersion = response:match("version%s+'([%d%.]+)'") or response:match('version%s+"([%d%.]+)"')
        
        if not latestVersion then
            print('^3[' .. resource .. '] ^7Unable to parse version from GitHub^0')
            return
        end
        
        if currentVersion ~= latestVersion then
            print('^0====================================^0')
            print('^3[' .. resource .. '] ^1Update Available!^0')
            print('^7Current Version: ^3' .. currentVersion .. '^0')
            print('^7Latest Version: ^2' .. latestVersion .. '^0')
            print('^7Download: ^5https://github.com/LumaNodeStudios/LNS_ItemThrowing^0')
            print('^0====================================^0')
        else
            print('^2[' .. resource .. '] ^7You are running the latest version (^2' .. currentVersion .. '^7)^0')
        end
    end, 'GET')
end)