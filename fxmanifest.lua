fx_version 'adamant'

game 'gta5'

description 'hrp_pd_impound'

client_scripts {
	"@es_extended/locale.lua",
	"config.lua",
	"json.lua",
	"client/client_impound.lua",

}

server_scripts {
	"@es_extended/locale.lua",
	"@mysql-async/lib/MySQL.lua",
	"config.lua",
	"json.lua",
	"server/server_impound.lua",

}

ui_page('web/index.html')
files {
    'config.json',
    'web/index.html',
    'web/script.js',
    'web/style.css'
}
