---@diagnostic disable: undefined-global
local QBCore = exports['qb-core']:GetCoreObject()

-- Funaction

local function getStorgesFile(name)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorges = {}
    for _, storge in ipairs(storges) do
        if storge.name == name then
            table.insert(playerStorges, storge)
        end
    end
    if #playerStorges > 0 then
        return playerStorges
    end
    return playerStorges
end

local function getIdStorgesFileBlip(id)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local getIdStorgesBlip = {}
    for _, storge in ipairs(storges) do
        if storge.id == id then
            table.insert(getIdStorgesBlip, storge)
        end
    end
    if #getIdStorgesBlip > 0 then
        return getIdStorgesBlip
    end
    return getIdStorgesBlip
end

local function setStorgeFiles(name, coords, width, height, options, price, maxWeight, slots, id, password)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local newStorge = {
        name = name,
        coords = coords,
        width = width,
        height = height,
        options = options,
        price = price,
        maxWeight = maxWeight,
        slots = slots,
        id = id,
        password = password
    }
    table.insert(storges, newStorge)
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

local function checkIdInStorge(id)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.id == id then
            return true
        end
    end
    return false
end

local function editIdStorgeFilesPass(id, name, password)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.id == id and storge.name == name then
            storge.password = password
        end
    end
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

local function editIdStorgeFilesOwnerID(id, name, password, newOwnerId)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.id == id and storge.name == name then
            storge.password = password
            storge.id = tostring(newOwnerId or id)
        end
    end
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

local function editNameStorgeFilByPolice(name, id)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.name == name then
            storge.statusLock = false
            storge.byPoliceId = id
            storge.date = string.format("%s", os.date("%Y-%m-%d %H:%M:%S"))
        end
    end
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

local function editNameLockStorgeFilByPolice(name, id, reason)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.name == name then
            storge.statusLock = false
            storge.byPoliceId = id
            storge.reason = reason
            storge.byPoliceIdLock = true
            storge.date = string.format("%s", os.date("%Y-%m-%d %H:%M:%S"))
        end
    end
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

local function editRepairStorgeLock(name, id)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.name == name and storge.id == id then
            storge.statusLock = nil
            storge.date = string.format("%s", os.date("%Y-%m-%d %H:%M:%S"))
        end
    end
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

local function editUnRepairStorgeLock(name, id)
    local filePath = "storges.json"
    local fileData = LoadResourceFile(GetCurrentResourceName(), filePath) or "[]"
    local storges = json.decode(fileData) or {}
    local playerStorgesById = {}
    for _, storge in ipairs(storges) do
        if storge.name == name and storge.id == id then
            storge.statusLock = nil
            storge.byPoliceId = nil
            storge.reason = nil
            storge.byPoliceIdLock = nil
            storge.date = string.format("%s", os.date("%Y-%m-%d %H:%M:%S"))
        end
    end
    SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(storges), -1)
end

-- Events

RegisterNetEvent("ph-storge:server:openOnleyStorge")
AddEventHandler("ph-storge:server:openOnleyStorge", function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local storge = getStorgesFile(id)
    if not storge or #storge == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "المستودع للبيع والمعرف:#"..id, "error", 5000)
    end

    local storgeData = storge[1]
    local password = storgeData.password
    local storgeName = storgeData.name
    local storgeId = storgeData.id
    local storgeStatusLock = storgeData.statusLock
    local storgeByPoliceId = storgeData.byPoliceId
    local storgebyPoliceIdLock = storgeData.byPoliceIdLock

    if storgebyPoliceIdLock == true then
        return TriggerClientEvent('QBCore:Notify', src, "المستودع محجوز من قبل الشرطة، راجع المركز", "error", 5000)
    elseif storgeStatusLock == false then
        -- exports['qb-inventory']:OpenInventory(src, "ph_storg|"..storgeData.name.."|"..storgeData.id, {
        --     label = "ph_storg|"..storgeData.name.."|"..storgeData.id,
        --     maxweight = storgeData.maxweight,
        --     slots = storgeData.slots,
        -- })
        -- TriggerEvent("inventory:server:OpenInventory", "stash", storgeData.name)
        -- exports['qb-inventory']:OpenInventory("stash", storgeData.name, { maxweight = storgeData.maxweight, slots = storgeData.slots }, source)
        -- TriggerClientEvent("inventory:client:SetCurrentStash",source, storgeData.name)
        TriggerClientEvent("ph-storge:client:openNowStorgeBoy",source, storgeData.name, storgeData.maxweight, storgeData.slots)

    else
        TriggerClientEvent('ph-storge:client:openStorge', src, storgeId, storgeName, password)
    end
end)

RegisterNetEvent("ph-storge:server:openStorge")
AddEventHandler("ph-storge:server:openStorge", function(id,name, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local storge = getStorgesFile(name)
    if not storge or #storge == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "لا يوجد هنا مستودع", "error", 5000)
    end
    local storgeData = storge[1]
    local storedPassword = storgeData.password
    if tonumber(password) ~= storedPassword then
        return TriggerClientEvent('QBCore:Notify', src, "كلمة المرور غير صحيحة", "error", 5000)
    end
    TriggerClientEvent("ph-storge:client:openNowStorgeBoy",source, storgeData.name, storgeData.maxweight, storgeData.slots)
end)

RegisterNetEvent("ph-storge:server:BuyStorgeExit")
AddEventHandler("ph-storge:server:BuyStorgeExit", function(data, input)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local name = data.name
    local coords = data.coords
    local width = data.width
    local height = data.height 
    local options = data.options 
    local price = data.price 
    local maxWeight = data.maxWeight 
    local slots = data.slots
    local cid = input.cid
    local password = input.password
    if not name or not coords or not width or not height or not options or not price or not maxWeight or not slots or not cid or not password then
        return QBCore.Functions.Notify(src, "كلمة المرور او الهوية غير صحيحة", "error")
    end
    local storgeData = getStorgesFile(name)
    if storgeData and #storgeData > 0 then
        QBCore.Functions.Notify(src, "المستودع محجوز مسبقًا", "error")
        return
    end
    if storgeData.id == tostring(Player.PlayerData.citizenid) then
        QBCore.Functions.Notify(src, "لا يمكنك شراء مستودع خاص بك", "error")
        return
    end
    if checkIdInStorge(tostring(Player.PlayerData.citizenid)) then
        QBCore.Functions.Notify(src, "غير مسموح بأمتلاك أكثر من مستودع 1، لديك مستودع", "error")
        return
    end

    local paymentMethod = Player.Functions.GetMoney('bank') >= price and 'bank' or Player.Functions.GetMoney('cash') >= price and 'cash' or nil
    if paymentMethod then
        Player.Functions.RemoveMoney(paymentMethod, price, 'شراء مستودع')
        TriggerClientEvent('QBCore:Notify', src, string.format("تم شراء مستودع بـ %s ", price), "success", 5000)
        TriggerClientEvent('ph-storge:client:createBlipNow', src)
        setStorgeFiles(name, coords, width, height, options, price, maxWeight, slots, tostring(Player.PlayerData.citizenid), tonumber(password))
    else
        TriggerClientEvent('QBCore:Notify', src, string.format("ليس لديك %s في رصيدك/البنك", price), "error", 5000)
    end
end)

RegisterNetEvent("ph-storge:server:changePasswordStorge")
AddEventHandler("ph-storge:server:changePasswordStorge", function(data, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local storgeData = getStorgesFile(data.name)
    if not storgeData or #storgeData == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "لا يوجد هنا مستودع", "error", 5000)
    end
    if storgeData[1].id ~= tostring(Player.PlayerData.citizenid) then
        return TriggerClientEvent('QBCore:Notify', src, "لا يمكنك تغيير كلمة المرور لمستودع ليس لك", "error", 5000)
    end
    if not password or password == "" then
        return TriggerClientEvent('QBCore:Notify', src, "كلمة المرور غير صحيحة", "error", 5000)
    end
    editIdStorgeFilesPass(storgeData[1].id, storgeData[1].name, password)
    QBCore.Functions.Notify(src, "تم تغيير كلمة المرور بنجاح", "success")
end) 

RegisterNetEvent("ph-storge:server:transferOwnershipStorge")
AddEventHandler("ph-storge:server:transferOwnershipStorge", function(data, newOwnerId, pass)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local PlayerOwnerId = QBCore.Functions.GetPlayerByCitizenId(newOwnerId) or QBCore.Functions.GetOfflinePlayerByCitizenId(newOwnerId)
    if not PlayerOwnerId then
        return TriggerClientEvent('QBCore:Notify', src, "الهوية غير صحيحة #1", "error", 5000)
    end
    if tostring(PlayerOwnerId.PlayerData.citizenid) == tostring(Player.PlayerData.citizenid) or tostring(PlayerOwnerId.PlayerData.citizenid) == data.id then
        return TriggerClientEvent('QBCore:Notify', src, "لا يمكنك نقل الملكية لنفسك", "error", 5000)
    end
    local storgeData = getStorgesFile(data.name)
    if not storgeData or #storgeData == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "لا يوجد هنا مستودع", "error", 5000)
    end
    if storgeData[1].id ~= tostring(Player.PlayerData.citizenid) then
        return TriggerClientEvent('QBCore:Notify', src, "لا يمكنك نقل ملكية مستودع ليس لك", "error", 5000)
    end
    if not newOwnerId or newOwnerId == "" then
        return TriggerClientEvent('QBCore:Notify', src, "الهوية غير صحيحة #2", "error", 5000)
    end
    if not pass or pass == "" or pass ~= data.password then
        return TriggerClientEvent('QBCore:Notify', src, "كلمة المرور غير صحيحة", "error", 5000)
    end

    editIdStorgeFilesOwnerID(storgeData[1].id, storgeData[1].name, pass, newOwnerId)

    TriggerClientEvent('ph-storge:client:createBlipNow', src)
    QBCore.Functions.Notify(src, "تم نقل الملكية بنجاح", "success")

    TriggerClientEvent('ph-storge:client:createBlipNow', PlayerOwnerId.PlayerData.source)
    QBCore.Functions.Notify(PlayerOwnerId.PlayerData.source, "تم نقل ملكية المستودع إليك", "success")
end)

RegisterNetEvent("ph-storge:server:openStorgeByPolice")
AddEventHandler("ph-storge:server:openStorgeByPolice", function(name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local storge = getStorgesFile(name)
    if not storge or #storge == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "لا يوجد هنا مستودع", "error", 5000)
    end
    local storgeData = storge[1]
    TriggerClientEvent("ph-storge:client:openNowStorgeBoy",source, storgeData.name, storgeData.maxweight, storgeData.slots)
    editNameStorgeFilByPolice(name, Player.PlayerData.citizenid)
end)

RegisterNetEvent("ph-storge:server:lockStorgeByPolice")
AddEventHandler("ph-storge:server:lockStorgeByPolice", function(name, id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local storge = getStorgesFile(name)
    if not storge or #storge == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "لا يوجد هنا مستودع", "error", 5000)
    end

    local storgeData = storge[1]
    
    if storgeData.byPoliceIdLock == true then
        return TriggerClientEvent('QBCore:Notify', src, "المستودع محجوز مسبقًا", "error", 5000)
    end

    editNameLockStorgeFilByPolice(name, Player.PlayerData.citizenid)

    TriggerClientEvent('QBCore:Notify', src, "تم حجز المستودع بنجاح", "success", 5000)
    TriggerClientEvent('QBCore:Notify', storgeData.id, "تم حجز المستودع من قبل الشرطة", "error", 5000)

    TriggerClientEvent('ph-storge:client:createBlipNow', src)
end)

RegisterNetEvent("ph-storge:server:repairStorgeLock")
AddEventHandler("ph-storge:server:repairStorgeLock", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local storge = getStorgesFile(data.name)
    if not storge or #storge == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "لا يوجد هنا مستودع", "error", 5000)
    end

    local storgeData = storge[1]
    local price = Config.PriceRepairStorgeLock
    if storgeData.statusLock == false then
        local paymentMethod = Player.Functions.GetMoney('bank') >= price and 'bank' or Player.Functions.GetMoney('cash') >= price and 'cash' or nil
        if paymentMethod then
            Player.Functions.RemoveMoney(paymentMethod, price, 'إصلاح قفل المستودع')
            editRepairStorgeLock(data.name, tostring(Player.PlayerData.citizenid))
            TriggerClientEvent('QBCore:Notify', src, string.format("تم إصلاح قفل المستودع بـ %s ", price), "success", 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, string.format("ليس لديك %s في رصيدك/البنك", price), "error", 5000)
        end
    else
    end
end)

RegisterNetEvent("ph-storge:server:removeRepairStorgeLock")
AddEventHandler("ph-storge:server:removeRepairStorgeLock", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local storge = getStorgesFile(data.name)
    if not storge or #storge == 0 then
        return TriggerClientEvent('QBCore:Notify', src, "هذا المستودع غير موجود", "error", 5000)
    end

    local storgeData = storge[1]
    editUnRepairStorgeLock(data.name, tostring(Player.PlayerData.citizenid))
    TriggerClientEvent('QBCore:Notify', src, "تم إلغاء حجز المستودع بنجاح", "success", 5000)
end)

-- Callbacks

QBCore.Functions.CreateCallback("ph-storge:server:getAvailableStorages", function(source, cb, id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local tableStorge = {}
    if #Config.Storge > 0 then
        for _, storge in pairs(Config.Storge) do
            local storgeName = storge[1]
            local storgeCoords = storge[2]
            local storgeData = getStorgesFile(storgeName)
            if not storgeData or #storgeData == 0 then
                local storgeInfo = {
                    name = storge[1],
                    coords = storge[2],
                    width = storge[3],
                    height = storge[4],
                    options = storge[5],
                    price = storge[6],
                    maxWeight = storge[7],
                    slots = storge[8],
                }
                table.insert(tableStorge, storgeInfo)
            end
        end
        if #tableStorge > 0 then
            return cb(tableStorge)
        else
            return cb(nil)
        end
    else
        return cb(nil)
    end
end)

QBCore.Functions.CreateCallback("ph-storge:server:BuyStorge", function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not data then
        QBCore.Functions.Notify(source, "لا يوجد المستودع غير موجود", "error")
        return cb(false)
    end
    local name = data.name
    local coords = data.coords
    local width = data.width
    local height = data.height 
    local options = data.options 
    local price = data.price 
    local maxWeight = data.maxWeight 
    local slots = data.slots
    if not name or not coords or not width or not height or not options or not price or not maxWeight or not slots then
        return cb(false)
    end
    local storgeData = getStorgesFile(name)
    if storgeData and #storgeData > 0 then
        QBCore.Functions.Notify(source, "المستودع محجوز مسبقًا", "error")
        return cb(false)
    end

    if storgeData.id == tostring(Player.PlayerData.citizenid) then
        QBCore.Functions.Notify(source, "لا يمكنك شراء مستودع خاص بك", "error")
        return cb(false)
    end
    if checkIdInStorge(tostring(Player.PlayerData.citizenid)) then
        QBCore.Functions.Notify(source, "غير مسموح بأمتلاك أكثر من مستودع 1، لديك مستودع", "error")
        return cb(false)
    end
    return cb(true)
end)

QBCore.Functions.CreateCallback('ph-storge:server:getIdStorgesFileBlip', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return cb(false)
    end
    local success = getIdStorgesFileBlip(tostring(Player.PlayerData.citizenid))
    if not success or #success == 0 then
        return cb(false)
    end
    for _, storge in ipairs(success) do
        if storge.byPoliceId then
            local GetbyPoliceId = QBCore.Functions.GetPlayerByCitizenId(storge.byPoliceId) or QBCore.Functions.GetOfflinePlayerByCitizenId(storge.byPoliceId)
            if GetbyPoliceId then
                storge.namePolice = string.format("%s %s", GetbyPoliceId.PlayerData.charinfo.firstname, GetbyPoliceId.PlayerData.charinfo.lastname)
            else
                storge.namePolice = "الشرطة - "..storge.byPoliceId
            end
        end
    end
    cb(success)
end)

QBCore.Functions.CreateCallback('ph-storge:server:controlStorgeAdmin', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return cb(false)
    end
    local success = getIdStorgesFileBlip(tostring(data.id))
    if not success or #success == 0 then
        return cb(false)
    end
    for _, storge in ipairs(success) do
        if storge.byPoliceId then
            local GetbyPoliceId = QBCore.Functions.GetPlayerByCitizenId(storge.byPoliceId) or QBCore.Functions.GetOfflinePlayerByCitizenId(storge.byPoliceId)
            if GetbyPoliceId then
                storge.namePolice = string.format("%s %s", GetbyPoliceId.PlayerData.charinfo.firstname, GetbyPoliceId.PlayerData.charinfo.lastname)
            else
                storge.namePolice = "الشرطة - "..storge.byPoliceId
            end
        end
    end
    cb(success)
end)