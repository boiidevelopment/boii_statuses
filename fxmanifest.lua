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

fx_version 'cerulean'
games { 'gta5', 'rdr3' }

name 'boii_statuses'
version '0.1.1'
description 'BOII | Development - Statuses'
author 'boiidevelopment'
repository 'https://github.com/boiidevelopment/boii_statuses'
lua54 'yes'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/config.lua',
    'server/main.lua',
    'server/player/player.lua',
    'server/statuses/*',
    'server/test.lua'
}

client_scripts {
    'client/config.lua',
    'client/main.lua',
    'client/player/player.lua',
    'client/statuses/*',
    'client/test.lua'
}

escrow_ignore {
    'client/*',
    'server/*'
}
