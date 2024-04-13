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

--- @todo Replace prints with debug_log function

--- @section Database queries

--- Update query
local UPDATE_QUERY = 'UPDATE player_statuses SET %s WHERE player = ?'

--- @section Constants

local DEFAULT_STATUSES = config.statuses.defaults
local DEFAULT_FLAGS = config.flags
local DEFAULT_INJURIES = config.injuries
local DEFAULT_POSITION = config.locations.spawn
local STATUS_REDUCTION_TIMER = config.statuses.reduction_timer
local DEFAULT_DATATYPES = { 'statuses', 'flags', 'injuries', 'buffs', 'debuffs', 'position' }  

--- @section Local functions

--- Helper function to process data types.
-- Returns data_types if it's not empty, otherwise returns default DEFAULT_DATATYPES.
-- @param data_types table: An array of data types to set (e.g., {'statuses'}, {'flags'}).
-- @return table: The processed data types.
-- @usage
--[[
    local data_types = process_data_types(data_types)
]]
-- @see self.set_data, self.save_data
local function process_data_types(data_types)
    return next(data_types) and data_types or DEFAULT_DATATYPES
end

--- @section Player object

--- Creates status object on player
-- @param _src: Player's source.
-- @param player_id: Players unique id; passport, citizenid, stateId.. etc..
-- @param data: Table of data for statuses/flags/position.
function create_status_object(_src, player_id, data)
    local function creation()
        if not _src or not player_id or not data then
            print('missing params')
            return
        end

        print('creating status object for player ' .. _src)

        local self = {}
        self.source = _src
        self.player_id = player_id
        self.data = data or {}

        self.data.statuses = self.data.statuses or DEFAULT_STATUSES
        self.data.flags = self.data.flags or DEFAULT_FLAGS
        self.data.injuries = self.data.injuries or DEFAULT_INJURIES
        self.data.buffs = self.data.buffs or {}
        self.data.debuffs = self.data.debuffs or {}
        self.data.position = self.data.position or DEFAULT_POSITION
        
        function self.status_reductions()
            if self.data.flags.dead then return end
            local function random_reduction(min, max, current)
                local reduction = math.random(min, max)
                return utils.maths.round(math.max(0, current - reduction), 0)
            end
            self.data.statuses.hunger = random_reduction(config.statuses.periodic_adjustments.hunger.min, config.statuses.periodic_adjustments.hunger.max, self.data.statuses.hunger)
            self.data.statuses.thirst = random_reduction(config.statuses.periodic_adjustments.thirst.min, config.statuses.periodic_adjustments.thirst.max, self.data.statuses.thirst)
            if self.data.statuses.hunger == 0 or self.data.statuses.thirst == 0 then
                self.data.statuses.health = random_reduction(config.statuses.periodic_adjustments.health.min, config.statuses.periodic_adjustments.health.max, self.data.statuses.health)
            end
            self.data.statuses.hygiene = random_reduction(config.statuses.periodic_adjustments.hygiene.min, config.statuses.periodic_adjustments.hygiene.max, self.data.statuses.hygiene)
            if self.data.statuses.hygiene < 20 then
                self.data.statuses.stress = math.min(100, self.data.statuses.stress + math.random(config.statuses.periodic_adjustments.stress.min, config.statuses.periodic_adjustments.stress.max))
            end
            self.set_data({ 'statuses' }, true)
            if self.data.statuses.health == 0 then
                self.kill_player()
            end
        end

        function self.modify_statuses(status_effects)
            for status, effect in pairs(status_effects) do
                local current_value = self.data.statuses[status] or 0
                local new_value = current_value + (effect.add or 0) - (effect.remove or 0)
                if status == 'health' then
                    new_value = math.min(200, math.max(0, new_value))
                else
                    new_value = math.min(100, math.max(0, new_value))
                end
                self.data.statuses[status] = new_value
                print('Updated ' .. status .. ' for player ' .. tostring(self.source) .. ': ' .. tostring(new_value - current_value))
            end
            self.set_data({ 'statuses' }, true)
        end

        function self.kill_player()
            print('Player Method: kill_player | Player ' .. self.source .. ' has died due to lack of resources.')
            self.data.statuses.health = 0
            self.data.statuses.hunger = 0
            self.data.statuses.thirst = 0
            self.data.statuses.hygiene = 0
            self.data.statuses.stress = 0
            self.data.statuses.armour = 0
            self.data.statuses.oxygen = 0
            self.data.statuses.stamina = 0
            self.data.flags.dead = true
            self.set_data({ 'statuses', 'flags' }, true)
            TriggerEvent('boii_statuses:sv:player_died', self.source)
        end

        function self.revive_player()
            print('Player Method: revive_player | Player ' .. self.source .. ' is being revived.')
            self.data.statuses.health = 200
            self.data.statuses.hunger = 100
            self.data.statuses.thirst = 100
            self.data.statuses.hygiene = 100
            self.data.statuses.stress = 0
            self.data.statuses.armour = 0
            self.data.statuses.oxygen = 100
            self.data.statuses.stamina = 100
            self.data.flags.dead = false
            self.set_data({ 'statuses', 'flags' }, true)
            self.status_reductions()
            print('Player Method: revive_player | Player ' .. self.source .. ' has been revived and statuses reset.')
        end

        function self.apply_effect(effect_type, id)
            local effect_config = (effect_type == 'buffs' and config.buffs[id]) or (effect_type == 'debuffs' and config.debuffs[id])
            if not effect_config then
                print(('Effect of type %s with ID %s not found.'):format(effect_type, tostring(id)))
                return
            end
            local current_time = os.time()
            local effects_table = self.data[effect_type][id]
            if effects_table and (current_time - effects_table.last_applied) < effect_config.cooldown then
                print(('Effect %s cannot be reapplied yet. Cooldown remaining: %s seconds.').format(id, effect_config.cooldown - (current_time - effects_table.last_applied)))
                return
            end
            self.data[effect_type][id] = { last_applied = current_time }
            if effect_config.on_apply then
                local action = effect_config.on_apply.action
                local action_type = effect_config.on_apply.action_type
                local params = effect_config.on_apply.params or {}
                if action_type == 'server' then
                    TriggerEvent(action, self.source, params)
                elseif action_type == 'client' then
                    TriggerClientEvent(action, self.source, params)
                else
                    print(('Unsupported action type %s for effect %s.').format(action_type, tostring(id)))
                end
            end
            self.set_data({ effect_type }, true)
            print(('Effect %s of type %s applied to player %s.').format(tostring(id), effect_type, self.source))
        end
        
        function self.remove_effect(effect_type, id)
            if not self.data[effect_type][id] then
                print(('Effect %s of type %s not found on player %s.').format(tostring(id), effect_type, self.source))
                return
            end
            local effect_config = (effect_type == 'buffs' and config.buffs[id]) or (effect_type == 'debuffs' and config.debuffs[id])
            if effect_config and effect_config.can_remove then
                self.data[effect_type][id] = nil
                if effect_config.on_remove then
                    local action = effect_config.on_remove.action
                    local action_type = effect_config.on_remove.action_type
                    local params = effect_config.on_remove.params or {}
                    if action_type == 'server' then
                        TriggerEvent(action, self.source, params)
                    elseif action_type == 'client' then
                        TriggerClientEvent(action, self.source, params)
                    end
                end
                self.set_data({ effect_type }, true)
                print(('Effect %s of type %s removed from player %s.').format(tostring(id), effect_type, self.source))
            else
                print(('Effect %s of type %s cannot be removed from player %s.').format(tostring(id), effect_type, self.source))
            end
        end
        
        function self.apply_injury(body_part, damage_amount)
            if config.injuries[body_part] then
                self.data.injuries[body_part] = self.data.injuries[body_part] or { damage = 0 }
                self.data.injuries[body_part].damage = math.min(100, self.data.injuries[body_part].damage + damage_amount)
                print("Injury applied to " .. body_part .. ": " .. self.data.injuries[body_part].damage)
                self.set_data({'injuries'}, true)
            else
                print("Invalid body part specified: " .. body_part)
            end
        end
        
        function self.heal_injury(body_part)
            if self.data.injuries[body_part] then
                self.data.injuries[body_part].damage = 0
                print(body_part .. " injury healed.")
                self.set_data({'injuries'}, true)
            else
                print("No existing injury to heal on: " .. body_part)
            end
        end
        

        function self.set_data(data_types, save_to_db)
            data_types = process_data_types(data_types)
            local data_table = {}
            for _, data_type in ipairs(data_types) do
                if self.data[data_type] then
                    data_table[data_type] = self.data[data_type]
                else
                    if DEFAULT_DATATYPES[data_type] then
                        print('Player Method: set_data | Note: Data type ' .. data_type .. ' not found in player data. Using default.')
                        data_table[data_type] = DEFAULT_DATATYPES[data_type]
                    else
                        print('Player Method: set_data failed. | Reason: Data type ' .. data_type .. ' not found in player data and no default available.')
                    end
                end
            end
            TriggerClientEvent('boii_statuses:cl:set_data', self.source, data_table)
            if save_to_db then
                self.save_data(data_types)
            end
        end

        function self.save_data(data_types)
            local data_types = process_data_types(data_types)
            local params = {}
            local fields = {}
            local params_index = 1
            for _, field in ipairs(data_types) do
                if self.data[field] then
                    params[params_index] = json.encode(self.data[field])
                    fields[params_index] = field .. ' = ?'
                    params_index = params_index + 1
                end
            end
            if #fields > 0 then
                params[params_index] = self.player_id
                local query_fields = table.concat(fields, ', ')
                MySQL.Async.execute(string.format(UPDATE_QUERY, query_fields), params, function(rows_changed)
                    if rows_changed > 0 then
                        print('Player Method: save_data | Data saved for player. ' .. self.source)
                    else
                        print('Player Method: save_data failed | Data save failed for player. ' .. self.source)
                    end
                end)
            else
                print('Player Method: save_data failed | No valid data fields provided for saving.')
            end
        end

        self.set_data({}, true)

        players[self.source] = self

        TriggerEvent('boii_statuses:player_joined', self)

        print('Finished creating status object for source: ' .. _src)
        return self
    end

    local function error_handler(err)
        print('Error occurred during player creation: ' .. tostring(err))
    end

    return utils.general.try_catch(creation, error_handler)
end

--- @section Global functions

--- Start status reductions for a player.
-- This function periodically reduces a player's status (e.g., hunger, thirst).
-- @param _src number: The player's source identifier.
function start_status_reductions(_src)
    CreateThread(function()
        while true do
            local player = get_player(_src)
            if player then
                player.status_reductions()
            else
                break
            end
            Wait(STATUS_REDUCTION_TIMER * 1000 * 60)
        end
    end)
end

--- @section Events

--- Event triggered when a player joins to set their routing bucket and start status reductions.
-- @param player table: The player object.
RegisterServerEvent('boii_statuses:player_joined', function(player)
    start_status_reductions(player.source)
    TriggerClientEvent('boii_statuses:cl:spawn_player', player.source, player.data.position)
    if player.data.flags.dead then
        TriggerClientEvent('boii_statuses:cl:player_died', player.source)
    end
end)

--- @section Event handlers

--- Handles the event when a player leaves (drops) from the server.
-- @function on_player_drop
-- @param reason string: The reason for the player's drop.
-- @local
local function on_player_drop(reason)
    local _src = source
    local name = GetPlayerName(_src)
    local player = get_player(_src)
    local coords = GetEntityCoords(GetPlayerPed(_src))
    local heading = GetEntityHeading(GetPlayerPed(_src))
    local position = {x = coords.x, y = coords.y, z = coords.z, w = heading}
    if player then
        player.data.position = position
        player.set_data({}, true)
        Wait(100)
        players[_src] = nil
    end
    print('Player: '..name..' was dropped from the server! Reason: '..reason)
end
AddEventHandler('playerDropped', on_player_drop)