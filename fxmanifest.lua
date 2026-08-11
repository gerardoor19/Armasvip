fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ArmasVIP Contributors'
description 'Menu VIP de armas con propiedad persistente, asignaciones y proteccion de transferencias'
version '2.3.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
    'shared/weapons.lua',
}

client_scripts {
    'client/menu.lua',
    'client/vip_durability.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/permissions.lua',
    'server/identity.lua',
    'server/grants.lua',
    'server/protection.lua',
    'server/callbacks.lua',
    'server/commands.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'locales/*.json',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'oxmysql',
}
