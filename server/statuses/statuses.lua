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

--- @section Database queries

--- Query to select a player from statuses table.
local SELECT_QUERY = 'SELECT player, statuses, flags, injuries, buffs, debuffs, position FROM player_statuses WHERE player = ?'

--- Query to insert a player into statuses table if data does not exist.
local INSERT_QUERY = 'INSERT INTO player_statuses (player, statuses, flags, injuries, buffs, debuffs, position) VALUES (?, ?, ?, ?, ?, ?, ?)'

--- @section Constants

local DEFAULT_STATUSES = config.statuses.defaults
local DEFAULT_FLAGS = config.flags
local DEFAULT_FLAGS = config.injuries
local DEFAULT_POSITION = config.locations.spawn
local USE_MULTICHAR = config.use_multichar

--- @section Local functions

--- Gets or creates player statuses
-- @param _src: Players source.
local function init(_src)
    local player_id

    if USE_MULTICHAR then
        player_id = utils.fw.get_player_id(_src)
    else
        player_id = utils.connections.get_user(_src).unique_id
    end

    local result = MySQL.query.await(SELECT_QUERY, { player_id })
    if result and #result > 0 then
        local player_data = result[1]
        local data = {
            player = player_data.player,
            statuses = json.decode(player_data.statuses),
            flags = json.decode(player_data.flags),
            injuries = json.decode(player_data.injuries),
            buffs = json.decode(player_data.buffs),
            debuffs = json.decode(player_data.debuffs),
            position = json.decode(player_data.position)
        }
        create_status_object(_src, player_id, data)
    else
        MySQL.query.await(INSERT_QUERY, { player_id, json.encode(DEFAULT_STATUSES), json.encode(DEFAULT_FLAGS), json.encode(DEFAULT_FLAGS), json.encode({}), json.encode({}), json.encode(DEFAULT_POSITION),})
        local data = {
            player = player_id,
            statuses = DEFAULT_STATUSES,
            flags = DEFAULT_FLAGS,
            injuries = DEFAULT_INJURIES,
            buffs = {},
            debuffs = {},
            position = DEFAULT_POSITION
        }
        create_status_object(_src, player_id, data)
    end
end
exports('init', init)

--- @section Events

--- Event triggered when a player dies
-- @param player table: The player object.
RegisterServerEvent('boii_statuses:sv:player_died', function(player)
    utils.notify.send(player, {
        header = 'YOU DIED',
        message = 'Oh damn... you died..',
        type = 'info',
        duration = 3000
    })
    TriggerClientEvent('boii_statuses:cl:player_died', player)
end)

--- Event triggered when a player dies
-- @param player table: The player object.
RegisterServerEvent('boii_statuses:sv:revive_player', function()
    local _src = source
    local player = get_player(_src)
    player.revive_player()
    utils.notify.send(_src, {
        header = 'REVIVED',
        message = 'Someone is looking out for you! You feel as good as new!',
        type = 'info',
        duration = 3000
    })
    TriggerClientEvent('boii_statuses:cl:revive_player', player)
end)

--- Triggered from client to sync entity health
-- @param new_health number: The incoming entity health value.
RegisterServerEvent('boii_statuses:sv:sync_entity_health', function(new_health)
    local _src = source
    local player = get_player(_src)
    if player then
        local current_health = player.data.statuses.health or 100
        local health_diff = new_health - current_health
        if health_diff > 0 then
            player.modify_statuses({ health = { add = health_diff }})
        elseif health_diff < 0 then
            player.modify_statuses({ health = { remove = math.abs(health_diff) }})
        end
        if new_health <= 0 then
            player.kill_player()
        end
    end
end)