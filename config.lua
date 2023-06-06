-- Detailed description of each option at repository wiki - https://github.com/Hiype/hiype-cardelivery/wiki

Config = {}

-- Base configurations
Config.StartLocation = vector4(-78.10, -1392.16, 30.32, 178.21)
Config.StartPedModel = "g_m_y_lost_01"
Config.AddBlip = true
Config.UseTarget = true
Config.PayoutMethod = "cash"
Config.PayoutBasedOnDistance = true
Config.ProhibitCopsFromStartingJob = true

-- XP configurations
Config.JobXP = 200
Config.KeepPenalty = -300
Config.DestroyPenalty = -350

Config.XpGoals = {
    1500, -- Rank 2
    2500, -- Rank 3
    3000, -- Level 4
}

-- Timing configurations
-- Miliseconds
Config.VehicleDeleteTimeout = 30000
Config.MessageReceiveTimeStart = 1000
Config.MessageReceiveTimeEnd = 10000
Config.KeepVehicleTimer = 10000


-- Seconds
Config.CooldownTime = 200


-- Cop configurations
Config.CopModel = "csb_cop"
Config.VehicleModel = "police4"
Config.SpawnLocalPolice = true
Config.SpawnLocalPoliceChance = 1
Config.SendRealPoliceNotification = true
Config.SendRealPoliceNotificationChance = 1
Config.MinimumCopCount = 1


-- Command configurations
Config.PermissionLevel = "admin"


-- Spawn configurations
Config.Vehicles = {
    { -- Rank 1 START
        {model="zion", name="Ubermacht Zion"},
        {model="tailgater", name="Obey Tailgater"},
    }, -- Rank 1 END
    { -- Rank 2 START
        {model="bmwe39", name="BMW E39"},
        {model="subwrx", name="Subaru Impreza WRX STI 2004"},
    }, -- Rank 2 END
    { -- Rank 3 START
        {model="rs7", name="Audi RS7"},
        {model="f82", name="BMW M5"},
        {model="m6f13", name="BMW M6 F13"},
    }, -- Rank 3 END
    { -- Rank 4 START
        {model="sc18", name="Lamborghini SC18"},
        {model="senna", name="McLaren Senna"}
    }, -- Rank 4 END
}

Config.Spawns = {
    { name="Cypress flats", x=728.32, y=-1897.23, z=28.99, heading=264.75, copHeading=332.55, copx=741.46, copy=-1766.14, copz=28.29 },
    { name="Elysian Island", x=600.91, y=-2675.6, z=5.89, heading=188.38, copx=656.72, copy=-2791.2, copz=5.87, copHeading=289.29 },
    { name="La mesa inside a garage", heading=263.13, x=946.4, y=-1697.76, z=29.52, copHeading=332.55, copx=741.46, copy=-1766.14, copz=28.29 },
}

Config.Destinations = {
    { name="Pacific bluffs garage", x=-2011.74, y=-351.87, z=47.69, from=1200, to=1400 },
    { name="Chumash house parking lot", x=-3201.59, y=1152.77, z=9.24, from=1500, to=1700 },
    { name="Vineyard parking lot", x=-1921.22, y=2044.75, z=140.32, from=1800, to=2000 },
    { name="Sandyshores trailer park", x=1828.54, y=3863.04, z=33.28, from=2000, to=2200 },
}

