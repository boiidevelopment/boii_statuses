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

local function send_to_hud(_src, debuff_id)
    local debuff = config.debuffs[debuff_id]
    if not debuff then print('debuff not found') return end

    if HUD == 'boii_hud' then
        TriggerClientEvent('boii_hud:cl:add_debuff', _src, {
            id = debuff_id,
            label = debuff.label,
            icon = debuff.icon,
            description = debuff.description,
            colour = debuff.colour
        })
    end

end

local function apply_debuff(_src, debuff_config)
    if debuff_config.id == 'stamina' then
        TriggerClientEvent('boii_statuses:cl:add_stamina_debuff', _src, debuff_config)
        return
    end
end

local function remove_debuff(_src, debuff_config)
    if debuff_config.id == 'stamina' then
        TriggerClientEvent('boii_statuses:cl:remove_stamina_debuff', _src, debuff_config)
        return
    end
end

local function start_timeout(_src, player, debuff_id)
    SetTimeout(debuff.duration * 1000, function()
        if player.data.debuffs and player.data.debuffs[debuff_id] then

            if HUD == 'boii_hud' then
                TriggerClientEvent('boii_hud:cl:remove_debuff', _src, debuff_id)
            end

            player.remove_effect('debuffs', debuff_id)
        end
    end)
end

RegisterServerEvent('boii_statuses:sv:start_debuff', function(_src, data)
    local debuff_id = data.id
    local player = get_player(_src)
    if player then
        local debuff = config.debuffs[debuff_id]
        if debuff then
            send_to_hud(_src, debuff_id)
            local debuff_config = {
                id = debuff_id,
                duration = debuff.duration,
                cooldown = debuff.cooldown
            }
            apply_debuff(_src, debuff_config)
            if debuff.duration then
                start_timeout(_src, player, debuff_id)
            end
        else
            print("Buff config not found for:", debuff_id)
        end
    else
        print("Player object not found for source:", tostring(_src))
    end
end)

local function remove_from_hud(_src, debuff_id)
    local debuff = config.debuffs[debuff_id]
    if not debuff then print('debuff not found') return end
    if HUD == 'boii_hud' then
        TriggerClientEvent('boii_hud:cl:remove_debuff', _src, debuff_id)
    end
end

RegisterServerEvent('boii_statuses:sv:end_debuff', function(_src, debuff_id)
    local player = players[_src]
    if player then
        remove_from_hud(_src, debuff_id)

        local debuff = config.debuffs[debuff_id]
        if not debuff then print('debuff not found') return end

        local debuff_config = {
            id = debuff_id,
            duration = debuff.duration,
            cooldown = debuff.cooldown
        }

        remove_debuff(_src, debuff_config)
        player.remove_effect('debuffs', debuff_id)
    else
        print("Player object not found for source: " .. tostring(_src))
    end
end)
