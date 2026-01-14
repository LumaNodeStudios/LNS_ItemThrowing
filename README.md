# Features

- Ability to throw configured items.
- Interactive placement mode with rotation and surface detection
- World props that all players can see and pick up
- Safety Distance validation, cooldowns and automatic cleanup

# Requirements
- [ox_inventory](https://github.com/CommunityOx/ox_inventory)
- [ox_lib](https://github.com/CommunityOx/ox_lib)
- [ox_target](https://github.com/CommunityOx/ox_target)

# ox_inventory edits (Must do)

**ox_inventory/client.lua**

```
RegisterNUICallback('giveItem', function(data, cb)
    cb(1)

    if usingItem then return end

    if client.giveplayerlist then
        local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(playerPed), 3.0)
        local nearbyCount = #nearbyPlayers

        if nearbyCount == 0 then return end

        if nearbyCount == 1 then
            local option = nearbyPlayers[1]

            if not isGiveTargetValid(option.ped, option.coords) then return end

            return giveItemToTarget(GetPlayerServerId(option.id), data.slot, data.count)
        end

        local giveList, n = {}, 0

        for i = 1, #nearbyPlayers do
            local option = nearbyPlayers[i]

            if isGiveTargetValid(option.ped, option.coords) then
                local playerName = GetPlayerName(option.id)
                option.id = GetPlayerServerId(option.id)
                ---@diagnostic disable-next-line: inject-field
                option.label = ('[%s] %s'):format(option.id, playerName)
                n += 1
                giveList[n] = option
            end
        end

        if n == 0 then return end

        lib.registerMenu({
            id = 'ox_inventory:givePlayerList',
            title = 'Give item',
            options = giveList,
        }, function(selected)
            giveItemToTarget(giveList[selected].id, data.slot, data.count)
        end)

        return lib.showMenu('ox_inventory:givePlayerList')
    end

    if cache.vehicle then
        local targetSeat = nil
        
        if cache.seat == -1 then
            targetSeat = 0
        elseif cache.seat == 0 then
            targetSeat = -1
        end
        
        if targetSeat then
            local occupant = GetPedInVehicleSeat(cache.vehicle, targetSeat)
            
            if occupant ~= 0 and occupant ~= playerPed and IsEntityVisible(occupant) then
                return giveItemToTarget(GetPlayerServerId(NetworkGetPlayerIndexFromPed(occupant)), data.slot, data.count)
            end
        end
        
        return
    end

    local itemName = data.item or data.name
    
    if not itemName then
        local inventory = exports.ox_inventory:GetPlayerItems()
        if inventory and inventory[data.slot] then
            itemName = inventory[data.slot].name
        end
    end
    
    if itemName then
        client.closeInventory()
        exports.LNS_ItemThrowing:startGiveMode(itemName, data.slot, data.count)
    end
end)
```