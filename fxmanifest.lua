fx_version 'cerulean'
game 'gta5'

author 'ph-storge' 
description 'نظام إدارة تخزين شامل لإطار عمل QBCore، يسمح للاعبين بشراء وإدارة وتأمين وحدات التخزين باستخدام ميزات متقدمة مثل التحكم بالشرطة ونقل الملكية وإصلاح الأقفال, by: https://discord.com/users/927741280946094131'
version '1.2.0'
lua54 'yes'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu'
}