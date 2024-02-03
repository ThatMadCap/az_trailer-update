fx_version 'adamant'
games { 'gta5' }

description 'Az_trailer by Azeroth - edited by MadCap'
version '3.0'

client_scripts {
	'config.lua',
    'client/**/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
    'server/**/*.lua',
}

dependencies {
	'qb-core',
	'qb-target',
	'qb-menu',
}

lua54 'yes'
