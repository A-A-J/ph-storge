---@diagnostic disable: undefined-global, lowercase-global
local isLoggedIn = LocalPlayer.state.isLoggedIn
local QBCore = exports['qb-core']:GetCoreObject()
local playerPed = PlayerPedId()
local storgeSpawnTargetStatus = false
local pedsSpawned = false
local blip = nil
local pedBlip = nil
local menu = {
    {
        header = "مسؤول المستودعات",
        isMenuHeader = true
    },
    {
        header = "شراء مستودع جديد",
        params = {
            event = "ph-storge:client:createStorge"
        }
    },
    {
        header = "إدارة مستودعاتي",
        params = {
            event = "ph-storge:client:controlStorge"
        }
    },
    {
        header = "إدارة المستودع",
        params = {
            event = "ph-storge:client:controlStorgeAdmin"
        }
    },
    {
        header = "اغلاق القائمة",
        params = {
            event = "qb-menu:cleint:closeMenu"
        }
    },
}

-- function

local function AwaitCallback(name, ...)
    local promise = promise:new()
    QBCore.Functions.TriggerCallback(name, function(result)
        promise:resolve(result)
    end, ...)
    return Citizen.Await(promise)
end

local function storgeSpawnTarget()
    if not Config.Storge or storgeSpawnTargetStatus then return end
    for i, current in ipairs(Config.Storge) do
        local name = current[1]    
        local coords = current[2]
        local width = current[3]
        local height = current[4]
        local options = current[5]

        exports['qb-target']:AddBoxZone(name, coords, width, height, {
            name = name,
            heading = options.heading,
            debugPoly = options.debugPoly,
            minZ = options.minZ,
            maxZ = options.maxZ
        }, {
            options = {
                {
                    type = "client",
                    icon = "fas fa-box-open",
                    label = "فتح",
                    action = function()
                        TriggerServerEvent("ph-storge:server:openOnleyStorge", name)
                    end
                },
                {
                    type = "client",
                    icon = "fas fa-lock",
                    label = "كسر القفل",
                    action = function()
                        local function DoRamAnimation(bool)
                            local ped = PlayerPedId()
                            local dict = 'missheistfbi3b_ig7'
                            local anim = 'lift_fibagent_loop'
                            if bool then
                                RequestAnimDict(dict)
                                while not HasAnimDictLoaded(dict) do
                                    Wait(1)
                                end
                                TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, 1, -1, false, false, false)
                            else
                                RequestAnimDict(dict)
                                while not HasAnimDictLoaded(dict) do
                                    Wait(1)
                                end
                                TaskPlayAnim(ped, dict, 'exit', 8.0, 8.0, -1, 1, -1, false, false, false)
                            end
                        end
                        DoRamAnimation(true)
                        QBCore.Functions.Progressbar("lockpick", "جاري كسر القُفل", 10000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done
                            DoRamAnimation(false)
                            TriggerServerEvent("ph-storge:server:openStorgeByPolice", name)
                        end, function() -- Cancel
                            DoRamAnimation(false)
                        end)
                    end,
                    canInteract = function()
                        local job = QBCore.Functions.GetPlayerData().job.name
                        return job == "police"
                    end,
                },
                {
                    type = "client",
                    label = "حجز المستودع",
                    icon = "fas fa-house-lock",
                    action = function()
                        local input = exports['qb-input']:ShowInput({
                            header = "حجز المستودع",
                            submitText = "حجز",
                            inputs = {
                                {
                                    text = "هوية العسكري",
                                    name = "idPolice",
                                    type = "number",
                                    isRequired = true,
                                    default = QBCore.Functions.GetPlayerData().citizenid,
                                    disable = true
                                },
                                {
                                    text = "السبب",
                                    name = "reason",
                                    type = "text",
                                    isRequired = true,
                                    default = "يرجى إضافة سبب الحجز",
                                    min = 1,
                                    max = 50
                                }
                            }
                        })
                        if input then
                            local idPolice = tonumber(input.idPolice)
                            local reason = tostring(input.reason)
                            if idPolice and reason then
                                TriggerServerEvent("ph-storge:server:lockStorgeByPolice", name, idPolice, reason)
                            end
                        end
                    end,
                    canInteract = function()
                        local job = QBCore.Functions.GetPlayerData().job.name
                        return job == "police"
                    end,
                },
            },
            distance = 2.5
        })
    end

    storgeSpawnTargetStatus = true
end

local function storgeDeleteTarget()
    for _, current in ipairs(Config.Storge) do
        exports['qb-target']:RemoveZone(current[1])
    end
    storgeSpawnTargetStatus = false
end

local function spawnPeds()
    if not Config.Peds or pedsSpawned then return end
    for _, current in ipairs(Config.Peds) do
        local model = type(current.model) == 'string' and GetHashKey(current.model) or current.model
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        local ped = CreatePed(0, model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, 0, false)
        current.pedHandle = ped
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "ph-storge:client:openMenu",
                    icon = "fas fa-hand-paper",
                    label = "تحدث",
                }
            },
            distance = 3.5
        })

        pedBlip = AddBlipForCoord(current.coords.x, current.coords.y, current.coords.z)
        SetBlipSprite (pedBlip, current.SetBlipSprite)
        SetBlipDisplay(pedBlip, 4)
        SetBlipScale  (pedBlip, 0.5)
        SetBlipColour (pedBlip, 1)
        SetBlipAsShortRange(pedBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("<FONT FACE='Arb'>"..current.name)
        EndTextCommandSetBlipName(pedBlip)
    end

    pedsSpawned = true
end

local function deletePeds()
    if not Config.Peds or not next(Config.Peds) or not pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
    pedsSpawned = false
end

local function formatted(number)
    return string.format("%d", number):reverse():gsub("(%d%d%d)", "%1."):reverse()
end

local function createBlip()
    local getIdStorgesFileBlip = AwaitCallback('ph-storge:server:getIdStorgesFileBlip');
    if not getIdStorgesFileBlip or #getIdStorgesFileBlip <= 0 then return end
    for _, location in ipairs(getIdStorgesFileBlip) do
        blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite (blip, 587)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, 0.5)
        SetBlipColour (blip, 6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("<FONT FACE='Arb'>ﻲﻋﺩﻮﺘﺴﻣ")
        EndTextCommandSetBlipName(blip)
    end
end

local function deleteBlips()
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
    blip = nil
end

-- Event

RegisterNetEvent("ph-storge:client:openMenu", function ()
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("ph-storge:client:createStorge", function ()
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    QBCore.Functions.TriggerCallback('ph-storge:server:getAvailableStorages', function(storge)
        if storge then
            local menuStorge = {
                {
                    header = "مسؤول المستودعات",
                    isMenuHeader = true
                },
            }
            for i, v in ipairs(storge) do
                table.insert(menuStorge, {
                    header = v.name,
                    txt = "المساحة: "..formatted(v.slots).." | الوزن: "..formatted(v.maxWeight).."kg | السعر: $"..formatted(v.price),
                    params = {
                        event = "ph-storge:client:BuyStorge",
                        args = v
                    }
                })
            end
            table.insert(menuStorge, {
                header = "العودة",
                params = {
                    event = "ph-storge:client:openMenu"
                }
            })

            table.insert(menuStorge, {
                header = "اغلاق القائمة",
                params = {
                    event = "qb-menu:cleint:closeMenu"
                }
            })
            exports['qb-menu']:openMenu(menuStorge)
        else
            QBCore.Functions.Notify("لا يوجد مستودع متاح", "error")
        end
    end)
end)

RegisterNetEvent("ph-storge:client:createStorgeNow", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local input = exports['qb-input']:ShowInput({
        header = "شراء مستودع",
        submitText = "شراء",
        inputs = {
            {
                text = "كلمة المرور",
                des = "ادخل كلمة مرور تحتوي على ارقام ومن اربعة ارقام",
                name = "password",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            }
        }
    })
    if input then
        local pass = tonumber(input.password)
        if pass then
            TriggerServerEvent("ph-storge:server:createStorge", data, input)
        end
    end
end)

RegisterNetEvent("ph-storge:client:BuyStorge", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    QBCore.Functions.TriggerCallback("ph-storge:server:BuyStorge", function(status)
        if status then
            local input = exports['qb-input']:ShowInput({
                header = "شراء مستودع",
                submitText = "شراء",
                inputs = {
                    {
                        text = "الهوية",
                        des = "ادخل هوية المالك",
                        name = "cid",
                        type = "number",
                        isRequired = true,
                        default = QBCore.Functions.GetPlayerData().citizenid,
                        min = 1000,
                        max = 9999
                    },
                    {
                        text = "كلمة المرور",
                        des = "ادخل كلمة مرور تحتوي على ارقام ومن اربعة ارقام",
                        name = "password",
                        type = "number",
                        isRequired = true,
                        default = 0,
                        min = 1000,
                        max = 9999
                    }
                }
            })
            if input then
                local cid = tonumber(input.cid)
                local pass = tonumber(input.password)
                if cid and pass then
                    TriggerServerEvent("ph-storge:server:BuyStorgeExit", data, input)
                end
            end
        end
    end, data)
end)

RegisterNetEvent("ph-storge:client:createBlipNow", function()
    createBlip()
end)

-- Event openStorge

RegisterNetEvent("ph-storge:client:openStorge", function(storgeId, storgeName, password)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local input = exports['qb-input']:ShowInput({
        header = "إدارة المستودع",
        submitText = "فتح",
        inputs = {
            {
                text = "الهوية",
                des = "ادخل هوية المالك",
                name = "cid",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            },
            {
                text = "كلمة المرور",
                des = "ادخل كلمة مرور تحتوي على ارقام ومن اربعة ارقام",
                name = "password",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            }
        }
    })
    if input then
        local cid = tonumber(input.cid)
        local pass = tonumber(input.password)
        if cid and pass and tonumber(password) == pass and cid == tonumber(storgeId) then
            TriggerServerEvent("ph-storge:server:openStorge", storgeId, storgeName, password)
        else
            QBCore.Functions.Notify("كلمة المرور خاطئة", "error")
        end
    end
end)

-- Event control storge

RegisterNetEvent("ph-storge:client:controlStorge", function()
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local getIdStorgesFileBlip = AwaitCallback('ph-storge:server:getIdStorgesFileBlip');
    local menuStorge = {
        {
            header = "مستودعاتي",
            isMenuHeader = true
        },
    }
    if getIdStorgesFileBlip and #getIdStorgesFileBlip > 0 then
        for i, v in ipairs(getIdStorgesFileBlip) do
            table.insert(menuStorge, {
                header = v.name,
                txt = "المساحة: "..formatted(v.slots).." | الوزن: "..formatted(v.maxWeight).."kg",
                params = {
                    event = "ph-storge:client:optionControlStorge",
                    args = v
                }
            })
        end
    else
        table.insert(menuStorge, {
            header = "لاتوجد لديك مستودعات",
            disable = true,
        })
    end
    table.insert(menuStorge, {
        header = "العودة",
        params = {
            event = "ph-storge:client:openMenu"
        }
    })
    table.insert(menuStorge, {
        header = "اغلاق القائمة",
        params = {
            event = "qb-menu:cleint:closeMenu"
        }
    })
    exports['qb-menu']:openMenu(menuStorge)
end)

RegisterNetEvent("ph-storge:client:optionControlStorge", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local menuStorge = {
        {
            header = "إدارة المستودع",
            isMenuHeader = true
        }
    }
    if data.byPoliceIdLock then
        print('data.byPoliceIdLock')
        table.insert(menuStorge, {
            header = "محجوز من قبل الشرطة",
            text = string.format("بواسطة: %s<br>السبب: %s<br>بتاريخ: %s", data.namePolice, data.reason or "راجع المركز", data.date),
            isDisabled = true,
        })
    elseif data.statusLock == false then
        table.insert(menuStorge, {
            header = "إصلاح باب الخزنة لانه مفتوح",
            text = "إصلاح باب الخزنة لانه مفتوح مقابل 2500 دولار",
            params = {
                event = "ph-storge:client:repairStorgeLock",
                args = data
            }
        })
    else
        table.insert(menuStorge, {
            header = "تغير كلمة المرور",
            params = {
                event = "ph-storge:client:changePasswordStorge",
                args = data
            }
        })
        table.insert(menuStorge, {
            header = "نقل الملكية",
            params = {
                event = "ph-storge:client:transferOwnershipStorge",
                args = data
            }
        })
    end
    table.insert(menuStorge, {
        header = "العودة",
        params = {
            event = "ph-storge:client:controlStorge"
        }
    })
    table.insert(menuStorge, {
        header = "اغلاق القائمة",
        params = {
            event = "qb-menu:cleint:closeMenu"
        }
    })
    exports['qb-menu']:openMenu(menuStorge)
end)

RegisterNetEvent("ph-storge:client:changePasswordStorge", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local input = exports['qb-input']:ShowInput({
        header = "تغير كلمة المرور",
        submitText = "تغير",
        inputs = {
            {
                text = "كلمة المرور الجديدة",
                des = "ادخل كلمة مرور تحتوي على ارقام ومن اربعة ارقام",
                name = "password",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            }
        }
    })
    if input then
        local pass = tonumber(input.password)
        if pass then
            TriggerServerEvent("ph-storge:server:changePasswordStorge", data, pass)
        end
    end
end)

RegisterNetEvent("ph-storge:client:transferOwnershipStorge", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local input = exports['qb-input']:ShowInput({
        header = "نقل الملكية",
        submitText = "نقل",
        inputs = {
            {
                text = "الهوية",
                des = "ادخل هوية المالك الجديد",
                name = "cid",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            },
            {
                text = "كلمة المرور الحالية",
                des = "ادخل كلمة مرور تحتوي على ارقام ومن اربعة ارقام",
                name = "password",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            }
        }
    })
    if input then
        local cid = tonumber(input.cid)
        local password = tonumber(input.password)
        if cid and password then
            TriggerServerEvent("ph-storge:server:transferOwnershipStorge", data, cid, password)
        end
    end
end)

RegisterNetEvent("ph-storge:client:repairStorgeLock", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    TriggerServerEvent("ph-storge:server:repairStorgeLock", data)
end)

RegisterNetEvent("ph-storge:client:controlStorgeAdmin", function()
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    if QBCore.Functions.GetPlayerData().job.name ~= "police" then
        return QBCore.Functions.Notify("هذا الامر مخصص لمسؤول المستودعات", "error")
    end
    local input = exports['qb-input']:ShowInput({
        header = "إدارة المستودع",
        submitText = "فتح",
        inputs = {
            {
                text = "الهوية",
                des = "ادخل هوية المالك",
                name = "cid",
                type = "number",
                isRequired = true,
                default = 0,
                min = 1000,
                max = 9999
            }
        }
    })
    if input then
        local cid = tostring(input.cid)
        if cid then
            local menuStorge = {
                {
                    header = "إدارة المستودع",
                    isMenuHeader = true
                }
            }
            local getStorgesByAdmin = AwaitCallback("ph-storge:server:controlStorgeAdmin", {id = cid})
            if not getStorgesByAdmin or #getStorgesByAdmin <= 0 then
                return QBCore.Functions.Notify("لاتوجد هوية مسجلة لدى مسؤول المستودعات", "error")
            end
            for i, v in ipairs(getStorgesByAdmin) do
                if v and v.id ~= cid then return QBCore.Functions.Notify("لاتوجد هوية مسجلة لدى مسؤول المستودعات", "error") end
                if v and v.byPoliceIdLock ~= true then return QBCore.Functions.Notify("لاتوجد حجوزات على صاحب هذه الهوية", "error") end
                table.insert(menuStorge, {
                    header = v.name,
                    text = string.format("بواسطة: %s<br>السبب: %s<br>بتاريخ: %s", v.namePolice, v.reason or "راجع المركز", v.date),
                    params = {
                        event = "ph-storge:client:controlStorgeAdminOptions",
                        args = v
                    }
                })
            end
            table.insert(menuStorge, {
                header = "العودة",
                params = {
                    event = "ph-storge:client:controlStorge"
                }
            })
            table.insert(menuStorge, {
                header = "اغلاق القائمة",
                params = {
                    event = "qb-menu:cleint:closeMenu"
                }
            })
            exports['qb-menu']:openMenu(menuStorge)
        end
    end
end)

RegisterNetEvent("ph-storge:client:controlStorgeAdminOptions", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    local menuStorge = {
        {
            header = "إدارة المستودع",
            isMenuHeader = true
        }
    }
    if not data.byPoliceIdLock then
        return QBCore.Functions.Notify("هذا المستودع غير محجوز", "error")
    end
    table.insert(menuStorge, {
        header = "إزالة الحجز",
        params = {
            event = "ph-storge:client:removeRepairStorgeLock",
            args = data
        }
    })
    table.insert(menuStorge, {
        header = "العودة",
        params = {
            event = "ph-storge:client:controlStorgeAdmin"
        }
    })
    table.insert(menuStorge, {
        header = "اغلاق القائمة",
        params = {
            event = "qb-menu:cleint:closeMenu"
        }
    })
    exports['qb-menu']:openMenu(menuStorge)
end)

RegisterNetEvent("ph-storge:client:removeRepairStorgeLock", function(data)
    if checkIsPedInAnyVehicle then return QBCore.Functions.Notify("يجب النزول من السيارة اولا", "error") end
    TriggerServerEvent("ph-storge:server:removeRepairStorgeLock", data)
end)

-- open storge

RegisterNetEvent("ph-storge:client:openNowStorgeBoy", function(name, maxweight, slots)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", name, {maxweight = maxweight, slots = slots})
    TriggerEvent("inventory:client:SetCurrentStash", name, {maxweight = maxweight, slots = slots})
    print(name)
end)

-- Event RegisterNetEvent FIVEM

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(3000)
    storgeSpawnTargetStatus = true
    createBlip()
    spawnPeds()
    storgeSpawnTarget()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    Wait(3000)
    PlayerData = {}
    deletePeds()
    storgeDeleteTarget()
    deleteBlips()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(3000)
    deletePeds()
    storgeDeleteTarget()
    deleteBlips()
end)

-- CreateThread

CreateThread(function()
    spawnPeds()
    storgeSpawnTarget()
    createBlip()
    while true do
        Wait(0)
        if isLoggedIn then
            playerPed = PlayerPedId()
            player_id = PlayerId()
            checkIsPedInAnyVehicle = IsPedInAnyVehicle(playerPed, false)
            isLoggedIn = LocalPlayer.state.isLoggedIn
        end
    end
end)