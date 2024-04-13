local TESTING = config.testing

if TESTING then

    RegisterCommand('test:add_buff', function(source, args, rawCommand)
        local player = get_player(source)
        if player then
            player.apply_effect('buffs', 'stamina')
        else
            print("Player object not found for source: "..tostring(source))
        end
    end, false)

    RegisterCommand('test:add_debuff', function(source, args, rawCommand)
        local player = get_player(source)
        if player then
            player.apply_effect('debuffs', 'stamina')
        else
            print("Player object not found for source: "..tostring(source))
        end
    end, false)

    RegisterCommand('test:remove_buff', function(source, args, rawCommand)
        local player = get_player(source)
        if player then
            player.remove_effect('buffs', 'stamina')
        else
            print("Player object not found for source: "..tostring(source))
        end
    end, false)

    RegisterCommand('test:remove_debuff', function(source, args, rawCommand)
        local player = get_player(source)
        if player then
            player.remove_effect('debuffs', 'stamina')
        else
            print("Player object not found for source: "..tostring(source))
        end
    end, false)

    RegisterCommand('test:injure', function(source, args, rawCommand)
        if #args < 2 then
            print("Usage: test:injure [body_part] [damage]")
            return
        end
        local body_part = tostring(args[1])
        local damage = tonumber(args[2])
        local player = get_player(source)
    
        if player and config.injuries[body_part] then
            player.apply_injury(body_part, damage)
        else
            print("Invalid body part or damage, or player object not found for source: "..tostring(source))
        end
    end, false)
    
    RegisterCommand('test:heal_injury', function(source, args, rawCommand)
        if #args < 1 then
            print("Usage: test:heal_injury [body_part]")
            return
        end
        local body_part = tostring(args[1])
        local player = get_player(source)
        if player and config.injuries[body_part] then
            player.heal_injury(body_part)
        else
            print("Invalid body part, or player object not found for source: "..tostring(source))
        end
    end, false)    

end
