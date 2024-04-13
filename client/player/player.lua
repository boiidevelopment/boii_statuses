--[[
     ____   ____ _____ _____   _   _____  ________      ________ _      ____  _____  __  __ ______ _   _ _______ 
    |  _ \ / __ \_   _|_   _| | | |  __ \|  ____\ \    / /  ____| |    / __ \|  __ \|  \/  |  ____| \ | |__   __|
    | |_) | |  | || |   | |   | | | |  | | |__   \ \  / /| |__  | |   | |  | | |__) | \  / | |__  |  \| |  | |   
    |  _ <| |  | || |   | |   | | | |  | |  __|   \ \/ / |  __| | |   | |  | |  ___/| |\/| |  __| | . ` |  | |   
    | |_) | |__| || |_ _| |_  | | | |__| | |____   \  /  | |____| |___| |__| | |    | |  | | |____| |\  |  | |   
    |____/ \____/_____|_____| | | |_____/|______|   \/   |______|______\____/|_|    |_|  |_|______|_| \_|  |_|   
                              | |                                                                                
                              |_|                STATUSES
]]

local HUD = config.hud

--- @section Events

--- Event to spawn player.
-- @param position table: A table containing the x, y, z coordinates and the w heading.
-- @usage TriggerEvent('boii_statuses:cl:spawn_player', position)
RegisterNetEvent('boii_statuses:cl:spawn_player', function(position)
    if not position then 
        debug_log('err', 'Event: boii_statuses:cl:spawn_player failed. | Reason: Position is missing.')
    end
    local player_ped = PlayerPedId()
    DoScreenFadeOut(1000)
    Wait(3000)
    SetEntityCoords(player_ped, position.x, position.y, position.z)
    SetEntityHeading(player_ped, position.w)
    DoScreenFadeIn(1000)
    if HUD == 'boii_hud' then
        exports.boii_hud:init()
    end
end)

--- Event to handle player deaths
RegisterNetEvent('boii_statuses:cl:player_died', function()
    exports.spawnmanager:setAutoSpawn(false)
    CreateThread(function()
        while true do
            local is_dead = IsEntityDead(PlayerPedId())
            local time_pressed = 0
            SetEntityHealth(PlayerPedId(), 0)
            if is_dead then
                while is_dead do
                    Wait(0)
                    local time_remaining = 5 - (time_pressed / 60)
                    -- Drawtext will be replaced asap for now.. it works. 
                    local function draw_text(text, y)
                        SetTextFont(0)
                        SetTextProportional(1)
                        SetTextScale(0.0, 0.35)
                        SetTextColour(255, 255, 255, 255)
                        SetTextDropshadow(0, 0, 0, 0, 255)
                        SetTextEdge(1, 0, 0, 0, 255)
                        SetTextDropShadow()
                        SetTextOutline()
                        SetTextCentre(true)
                        SetTextEntry('STRING')
                        AddTextComponentString(text)
                        DrawText(0.5, y)
                    end
                    draw_text('You are dead...', 0.45)
                    if time_remaining > 0 then
                        draw_text(string.format('Press and hold [E] to respawn %.1fs', time_remaining), 0.5)
                    else
                        draw_text('Releasing [E] will cancel respawn.', 0.5)
                    end
                    if IsControlPressed(0, utils.keys.get_key('e')) then
                        time_pressed = time_pressed + 1
                        if time_pressed >= 300 then
                            SetEntityHealth(PlayerPedId(), 200)
                            exports.spawnmanager:spawnPlayer({
                                x = config.respawn_location.x, y = config.respawn_location.y, z = config.respawn_location.z,
                            }, function()
                                SetEntityHealth(PlayerPedId(), 200)
                                exports.spawnmanager:setAutoSpawn(true)
                                TriggerServerEvent('boii_statuses:sv:revive_player')
                            end)
                            break
                        end
                    else
                        if time_pressed > 0 and time_pressed < 300 then
                            time_pressed = 0
                        end
                    end
                end
                break
            end
        end
    end)
end)

--- Set entity health back to full on revive
RegisterNetEvent('boii_statuses:cl:revive_player', function()
    SetEntityHealth(PlayerPedId(), 200)
end)

--- @section Threads

--- Ensures entity health is synced with statuses health.
CreateThread(function()
    local last_health = GetEntityHealth(PlayerPedId())
    while true do
        Wait(500)
        local entity_health = GetEntityHealth(PlayerPedId())
        if entity_health ~= last_health then
            TriggerServerEvent('boii_statuses:sv:sync_entity_health', entity_health)
            last_health = entity_health
        end
    end
end)