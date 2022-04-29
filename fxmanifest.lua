fx_version 'bodacious'
game 'gta5'

author 'https://github.com/Hiype'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
    'lang.lua',
}

client_scripts {
    'client/functions.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client/client.lua',
}

server_script 'server/server.lua'

lua54 'yes'