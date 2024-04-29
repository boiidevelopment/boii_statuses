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

--- @todo Add lua doc comments throughout

local HUD = config.hud

local function send_to_hud(_src, buff_id)
    local buff = config.buffs[buff_id]
    if not buff then print('buff not found') return end

    if HUD == 'boii_hud' then
        TriggerClientEvent('boii_hud:cl:add_buff', _src, {
            id = buff_id,
            label = buff.label,
            icon = buff.icon,
            description = buff.description,
            colour = buff.colour
        })
    end

end

local function apply_buff(_src, buff_config)
    if buff_config.id == 'stamina' then
        TriggerClientEvent('boii_statuses:cl:add_stamina_buff', _src, buff_config)
        return
    end
end

local function remove_buff(_src, buff_config)
    if buff_config.id == 'stamina' then
        TriggerClientEvent('boii_statuses:cl:remove_stamina_buff', _src, buff_config)
        return
    end
end

local function start_timeout(_src, player, buff_id)
    local buff = config.buffs[buff_id]
    SetTimeout(buff.duration * 1000, function()
        if player.data.buffs and player.data.buffs[buff_id] then

            if HUD == 'boii_hud' then
                TriggerClientEvent('boii_hud:cl:remove_buff', _src, buff_id)
            end

            player.remove_effect('buffs', buff_id)
        end
    end)
end

RegisterServerEvent('boii_statuses:sv:start_buff', function(_src, data)
    local buff_id = data.id
    local player = get_player(_src)
    if player then
        local buff = config.buffs[buff_id]
        if buff then
            send_to_hud(_src, buff_id)
            local buff_config = {
                id = buff_id,
                duration = buff.duration,
                cooldown = buff.cooldown
            }
            apply_buff(_src, buff_config)
            if buff.duration then
                start_timeout(_src, player, buff_id)
            end
        else
            print("Buff config not found for:", buff_id)
        end
    else
        print("Player object not found for source:", tostring(_src))
    end
end)

local function remove_from_hud(_src, buff_id)
    local buff = config.buffs[buff_id]
    if not buff then print('buff not found') return end
    if HUD == 'boii_hud' then
        TriggerClientEvent('boii_hud:cl:remove_buff', _src, buff_id)
    end
end

RegisterServerEvent('boii_statuses:sv:end_buff', function(_src, buff_id)
    local player = players[_src]
    if player then
        remove_from_hud(_src, buff_id)

        local buff = config.buffs[buff_id]
        if not buff then print('buff not found') return end

        local buff_config = {
            id = buff_id,
            duration = buff.duration,
            cooldown = buff.cooldown
        }

        remove_buff(_src, buff_config)
        player.remove_effect('buffs', buff_id)
    else
        print("Player object not found for source: " .. tostring(_src))
    end
end)
