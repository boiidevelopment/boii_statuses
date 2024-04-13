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

RegisterNetEvent('boii_statuses:cl:add_stamina_debuff', function()
    local stamina = GetPlayerMaxStamina(PlayerPedId()) / 2
    stamina_debuff = true
    CreateThread(function()
        while true do
            if stamina_debuff then
                ResetPlayerStamina(PlayerPedId())
                SetPlayerMaxStamina(PlayerPedId(), stamina)
                Wait(0)
            end
        end
    end)
end)

RegisterNetEvent('boii_statuses:cl:remove_stamina_debuff', function()
    stamina_debuff = false
    ResetPlayerStamina(PlayerPedId())
    RestorePlayerStamina(PlayerPedId(), 1.0)
end)