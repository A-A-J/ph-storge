Config = {}

Config.name_job = 'landtransp' -- اسم الوظيفة

Config.PriceRepairStorgeLock = 1500 -- سعر تصليح قفل المستودع

-- الشخصيات
Config.Peds = {
    {
        model = 's_m_m_lathandy_01',
        coords = vector3(-575.4248, -1635.3510, 18.4401),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        zoneOptions = {
            length = 3.0,
            width = 3.0
        },
        SetBlipSprite = 587,
        name = 'ﺕﺎﻋﺩﻮﺘﺴﻤﻟﺍ ﻝﻭﺆﺴﻣ',
    }
}

---- احداثيات المستودعات
Config.Storge = {
    {
        "مستودع_1",
        vector3(152.93, -1339.75, 29.2), 0.5, 2, {
            name = "storge_01",
            heading = 55,
            debugPoly = false,
            minZ = 27.0,
            maxZ = 31.0
        },
        75000, -- سعر المستودع
        65000, -- المساحة
        24, -- الخانات
    },
    {
        "مستودع_2",
        vector3(350.67, -1094.63, 29.41), 0.5, 3.5, {
            name = "storge_02",
            heading = 90,
            debugPoly = false,
            minZ = 27.61,
            maxZ = 31.61
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_3",
        vector3(333.25, -993.9, 29.24), 0.5, 3.5, {
            name = "storge_03",
            heading = 0,
            debugPoly = false,
            minZ = 27.44,
            maxZ = 31.44
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_4",
        vector3(734.34, -1284.3, 26.28), 0.5, 5, {
            name = "storge_04",
            heading = 90,
            debugPoly = false,
            minZ = 24.88,
            maxZ = 28.88
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_5",
        vector3(-3178.85, 1031.54, 20.3), 0.5, 4, {
            name = "storge_05",
            heading = 335,
            debugPoly = false,
            minZ = 18.3,
            maxZ = 22.3
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_6",
        vector3(-2946.95, 57.07, 11.61), 0.5, 3.5, {
            name = "storge_06",
            heading = 65,
            debugPoly = false,
            minZ = 9.01,
            maxZ = 13.01
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_7",
        vector3(72.08, -1425.26, 29.31), 0.5, 3, {
            name = "storge_07",
            heading = 320,
            debugPoly = false,
            minZ = 27.91,
            maxZ = 31.91
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_8",
        vector3(-73.01, -1820.41, 26.94), 0.5, 3.5, {
            name = "storge_08",
            heading = 50,
            debugPoly = false,
            minZ = 25.34,
            maxZ = 29.34
        },
        250000, -- سعر المستودع
        120000, -- المساحة
        45, -- الخانات
    },
    {
        "مستودع_9",
        vector3(1917.03, 3741.78, 32.58), 0.5, 5, {
            name = "storge_09",
            heading = 120,
            debugPoly = false,
            minZ = 29.98,
            maxZ = 33.98
        },
        10999, -- سعر المستودع
        15000, -- المساحة
        12, -- الخانات
    },
}