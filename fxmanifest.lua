fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Greve | Honeybadger Development - discord.gg/qGa4ngpgTg'
description 'Carry Bike'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@lation_ui/init.lua',
    'shared/config.lua'
}

client_script {
    'modules/client/client_carrybike.lua',
}

server_script {
    'modules/server/server_prints.lua',
}

dependencies {
    'ox_lib',
    'lation_ui'
}