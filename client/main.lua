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

--- @section Dependencies

--- Import utility library.
utils = exports['boii_utils']:get_utils()

--- @section Tables

local player_data = player_data or {}

--- @section Global functions

--- Handles debug logging.
-- @function debug_log
-- @param type string: The type of debug message.
-- @param message string: The debug message.
function debug_log(type, message)
    if config.debug and utils.debug[type] then
        utils.debug[type](message)
    end
end

--- Set data.
-- @param data_table table: A table containing the character data to be set.
-- @usage set_data({ 'statuses', 'flags' })
function set_data(data_table)
    for key, value in pairs(data_table) do
        player_data[key] = value
    end
end
exports('set_data', set_data)

--- Get data.
-- @param key string: The key for the specific data to retrieve (optional).
-- @usage
--[[
    -- Gets a specific section of player data
    local health = exports.boii_statuses:get_data('statuses').health

    -- Gets all player data
    local all_data = get_data()
]]
function get_data(key)
    if key then
        return player_data[key]
    else
        return player_data
    end
end
exports('get_data', get_data)

--- @section Events

--- Event to set data.
-- @param data table: A table containing the data to be set.
-- @usage 
--[[
    -- Used internally to sync data exposed by player object to client
    TriggerClientEvent('boii_statuses:cl:set_data', self.source, data)
]]
-- @see set_data
RegisterNetEvent('boii_statuses:cl:set_data', function(data)
    if not data then 
        debug_log('err', 'Event: boii_statuses:cl:set_data failed. | Reason: Data is missing.')
    end
    set_data(data)
end)



--- @section Assign local functions