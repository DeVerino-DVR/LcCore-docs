fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'

name 'LcCore'
description 'LastCountry Core Framework'
version '1.0.0'

-- Shared
shared_scripts {
    'config/config.lua',
    'shared/shared.lua',
}

-- Client
client_scripts {
    'client/dataview.lua',
    'client/callbacks.lua',
    'client/modules/**/*.lua',
    'client/spawn.lua',
    'client/api.lua',
    'client/main.lua',
}

-- Server
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/modules/core/database.lua',
    'server/callbacks.lua',
    'server/classes/*.lua',
    'server/modules/**/*.lua',
    'server/commands.lua',
    'server/api.lua',
    'server/main.lua',
}

-- UI
files {
    'ui/**/*',
}

ui_page 'ui/index.html'
