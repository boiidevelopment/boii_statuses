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

config = config or {}

--- Test mode
config.testing = true

--- Debug settings toggle
config.debug = true

--- Multicharacter toggle
-- @field boolean true | false: Status object will be created on a specific character | Status object will be created on the user using utils user_accounts.
config.use_multichar = true

--- Hud settings
config.hud = 'boii_hud' 

--- Locations table
-- @field spawn: Default spawn location for players.
-- @field respawn: Default respawn location for players.
config.locations = {
    spawn = vector4(-268.47, -956.98, 31.22, 208.54),
    respawn = vector4(341.28, -1396.83, 32.51, 48.78)
}

--- Statuses table
-- @field reduction_timer: This is the amount of time taken until another periodic status adjustment in minutes.
-- @field defaults: Table of default status values to add to players.
-- @field periodic_adjustments: Here your can set the rates at which player statuses will be reduced periodically.
-- @field hunger: Rate of decay for players hunger.
-- @field thirst: Rate of decay for players thirst.
-- @field health: Rate of decay for players health if hunger or thirst reaches 0.
-- @field stress: Rate of increase for players stress if hunger, thirst or hygiene is a low value.
-- @field hygiene: Rate of decay for player hygiene.
config.statuses = {
    reduction_timer = 5,
    defaults = {
        health = 200,
        armour = 0,
        hunger = 100,
        thirst = 100,
        stress = 0,
        stamina = 100,
        oxygen = 100,
        hygiene = 100
    },
    periodic_adjustments = {
        hunger = { min = 5, max = 10 },
        thirst = { min = 3, max = 7 },
        health = { min = 15, max = 25 },
        stress = { min = 2, max = 6 },
        hygiene = { min = 1, max = 3 }
    }
}

--- Flags table
-- @field defaults: Table of default flags for players.
-- @field dead, handcuffed, zipties, wanted, jailed, safezone, inside, grouped: Can be set on players when parameters are met for example if player is dead we flag them as dead so this is persistant when they rejoin.
config.flags = {
    dead = false,
    handcuffed = false,
    ziptied = false,
    wanted = false,
    jailed = false,
    safezone = false,
    inside = false,
    grouped = false
}

--- Injuries table
-- @field body_part: The body part to track.
-- @field damage: The amount of damage taken: 1 - 100
config.injuries = {
    head = { damage = 0 },
    upper_torso = { damage = 0 },
    lower_torso = { damage = 0 },
    forearm_right = { damage = 0 },
    hand_right = { damage = 0 },
    thigh_right = { damage = 0 },
    calf_right = { damage = 0 },
    foot_right = { damage = 0 },
    forearm_left = { damage = 0 },
    hand_left = { damage = 0 },
    thigh_left = { damage = 0 },
    calf_left = { damage = 0 },
    foot_left = { damage = 0 }
}

--- Buffs table
-- @field buff_type: The type of buff to set.
-- @field id: Unique ID for the buff.
-- @field label: Human readable name for the buff.
-- @field description: Buff description displayed on hover.
-- @field duration: Duration of the buff in seconds (s).
-- @field cooldown: Cooldown duration of the buff in seconds (s).
-- @field can_remove: Toggle if players can manually remove the buff by right clicking on it.
-- @field colour: Colours the box shadow outline and icon.
-- @field on_apply: Action to be performed when buff is applied to a player.
-- @field action_type: Type of action currently only supports events: 'client' | 'server'.
-- @field action: The event to trigger on apply.
-- @field params: Any additional parameters to use when applying.
-- @field on_remove: Action to be performed when buff is removed from a player.
-- @field action_type: Type of action currently only supports events: 'client' | 'server'.
-- @field action: The event to trigger on apply.
-- @field params: Any additional parameters to use when removing.
config.buffs = {

    stamina = {
        id = 'stamina',
        label = 'Endurance Boost',
        icon = 'fa-solid fa-heart-pulse',
        description = 'You feel invigorated! Your stamina regeneration has been increased by 100%.',
        duration = 30,
        cooldown = 60,
        can_remove = true,
        colour = 'white',
        on_apply = {
            action_type = 'server',
            action = 'boii_statuses:sv:start_buff',
            params = {
                id = 'stamina'
            }
        },
        on_remove = {
            action_type = 'server',
            action = 'boii_statuses:sv:end_buff',
            params = {
                id = 'stamina'
            }
        }
    }

}

--- Debuffs table
-- @field debuff_type: The type of debuff to set.
-- @field id: Unique ID for the debuff.
-- @field label: Human readable name for the debuff.
-- @field description: debuff description displayed on hover.
-- @field duration: Duration of the debuff in seconds (s).
-- @field cooldown: Cooldown duration of the debuff in seconds (s).
-- @field can_remove: Toggle if players can manually remove the debuff by right clicking on it.
-- @field colour: Colours the box shadow outline and icon.
-- @field on_apply: Action to be performed when debuff is applied to a player.
-- @field action_type: Type of action currently only supports events: 'client' | 'server'.
-- @field action: The event to trigger on apply.
-- @field params: Any additional parameters to use when applying.
-- @field on_remove: Action to be performed when debuff is removed from a player.
-- @field action_type: Type of action currently only supports events: 'client' | 'server'.
-- @field action: The event to trigger on apply.
-- @field params: Any additional parameters to use when removing.
config.debuffs = {

    stamina = {
        id = 'stamina',
        label = 'Fatigued',
        icon = 'fa-solid fa-heart-pulse',
        description = 'You feel fatigued! Your stamina regeneration has been reduced by 50%.',
        duration = 30,
        cooldown = 60,
        can_remove = true,
        colour = '#323030',
        on_apply = {
            action_type = 'server',
            action = 'boii_statuses:sv:start_debuff',
            params = {
                id = 'stamina'
            }
        },
        on_remove = {
            action_type = 'server',
            action = 'boii_statuses:sv:end_debuff',
            params = {
                id = 'stamina'
            }
        }
    }

}