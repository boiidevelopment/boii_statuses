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

--- @section Version check

--- Version check options
-- @field resource_name: The name of the resource to check, you can set a value here or use the current resource.
-- @field url_path: The path to your json file.
-- @field callback: Callback to invoking resource version check details *optional*
local opts = {
    resource_name = 'boii_statuses',
    url_path = 'boiidevelopment/fivem_resource_versions/main/versions.json',
}
utils.version.check(opts)

--- @field TABLE_QUERY table: Query to create the main battlepass table if does not already exist.
local TABLE_QUERY = [[
    CREATE TABLE IF NOT EXISTS `player_statuses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `player` varchar(255) NOT NULL,
    `statuses` json NOT NULL,
    `flags` json NOT NULL,
    `injuries` json NOT NULL,
    `buffs` json NOT NULL,
    `debuffs` json NOT NULL,
    `position` varchar(255) NOT NULL,
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
]]

--- @section Tables

players = players or {}

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

--- @section Local functions

--- Creates player statuses table if does not exist
local function create_table()
	MySQL.update(TABLE_QUERY, {})
end
create_table()

--- Get a specific player object by their source.
-- @param _src: Player's source.
-- @return The player object or nil if not found.
function get_player(_src)
    return players[_src] or nil
end
exports('get_player', get_player)