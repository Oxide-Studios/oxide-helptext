fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'oxide-helptext'
author 'Oxide Studios'
description 'Interaction prompts with key badges, stacking and per-resource ownership'
version '1.0.0'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'web/dist/assets/*.woff2',
    'compat/ox_lib.lua',
}

shared_scripts {
    'shared/config.lua',
}

client_scripts {
    'client/keys.lua',
    'client/parser.lua',
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

-- Consumed by the o-link helptext adapter (o-link/modules/helptext/oxide-helptext/client.lua).
client_exports { 'Show', 'Hide', 'HideAll', 'IsOpen' }

server_exports { 'Show', 'Hide', 'HideAll' }
