fx_version 'adamant'
games { 'gta5' }

description 'Az_trailer by Azeroth - edited by MadCap'
version '3.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua',
}

lua54 'yes'
