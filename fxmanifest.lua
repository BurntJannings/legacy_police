game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

client_script {
    'client/client.lua',
    'client/functions.lua',
    'client/menu.lua'

}

server_script {
    'server/server.lua'
}

shared_script {
    'locale.lua',
    'en.lua',
    'config/ConfigMain.lua',
    'config/ConfigWebhook.lua',
    'config/ConfigJail.lua',
    'config/ConfigCabinets.lua',
    'config/ConfigService.lua'

}
