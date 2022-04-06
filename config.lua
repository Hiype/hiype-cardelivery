-- Sends you a message of where and what car to get
notification = true
showAboveHead = true        -- Shows up above the npcs head, otherwise in HUD

-- Be able to use qb-target to start the job, disable if you do not have this resource
useTarget = true

-- Npc spawn location
showNpc = true
npcHeading = 205.9
npcCoords = vector3(-79.25, -1392.6, 29.32)
showblip = true

-- The amount of xp subtracted for keeping the car or destroying it
rankPenalty = -120
xpGain = 100

-- The size of the circle where player enters to start the job
startSize = 20

-- Cooldown in seconds that forbids players to take this job again if it was recently taken
cooldown = 120

-- Set true if you want to be able to keep the vehicle and cancel the job
abilityToKeepVehicle = true

-- DOES NOT WORK YET if set to true, but does not break the script, the job can still be completed
-- Should the stealable car be spawned with a driver so it drives around
driveAround = false

-- Time in seconds in which you need to choose to keep the vehicle
choiceTimer = 20

-- Payout adds money as cash, if false then adds it to your bank
payInCash = true

-- Change the string to have a different npc model
pedModel = GetHashKey("g_m_y_lost_01")

-- The possibility for a local cop car to spawn that chases after player
copSpawn = true
chanceToSpawnCop = 1        -- The chance that the cop spawns, for example 2 means 1/2 chance, 5 would be 1/5 chance and so on

-- Sends a notification to player cops
sendPoliceNotif = true
policeNotifChance = 2       -- 1 = 1/1 all the time, 2 = 1/2 50% of the time, etc.

-- Xp you need to reach that level, you can add more
levelXpGoal = {
    1500, -- Level 2
    2500, -- Level 3
    3000, -- Level 4
}

-- You should replace these custom vehicles if your server does not have them
-- You can add more levels
vehicles = {
    { -- Level 1
        {model="zion", name="Ubermacht Zion"},
        {model="tailgater", name="Obey Tailgater"},
    },
    { -- Level 2
        {model="bmwe39", name="BMW E39"},
        {model="subwrx", name="Subaru Impreza WRX STI 2004"},
    },
    { -- Level 3
        {model="rs7", name="Audi RS7"},
        {model="f82", name="BMW M5"},
        {model="m6f13", name="BMW M6 F13"},
    },
    { -- Level 4
        {model="sc18", name="Lamborghini SC18"},
        {model="senna", name="McLaren Senna"}
    },
}

-- Locations where parked vehicles spawn and cop cars
parked_spawns = {
    {name="Cypress flats", x=728.32, y=-1897.23, z=28.99, heading=264.75, copHeading=332.55, copx=741.46, copy=-1766.14, copz=28.29},
    {name="Elysian Island", x=600.91, y=-2675.6, z=5.89, heading=188.38, copx=656.72, copy=-2791.2, copz=5.87, copHeading=289.29},
    {name="La mesa inside a garage", heading=263.13, x=946.4, y=-1697.76, z=29.52, copHeading=332.55, copx=741.46, copy=-1766.14, copz=28.29},
}

-- Locations where driving vehicles spawn
drive_spawns = {
    {name="Little Seoul", heading=179, x=-789.6, y=-821.9, z=20.43},
    {name="Vespucci", heading=10.5, x=-1320.7, y=-1213.28, z=4.79},
}

-- Delivery locations for stolen vehicles
-- From - to is the range of the payout for delivering the vehicle
destinations = {
    {name="Pacific bluffs garage", x=-2011.74, y=-351.87, z=47.69, from=1200, to=1400},
    {name="Chumash house parking lot", x=-3201.59, y=1152.77, z=9.24, from=1500, to=1700},
    {name="Vineyard parking lot", x=-1921.22, y=2044.75, z=140.32, from=1800, to=2000},
    {name="Sandyshores trailer park", x=1828.54, y=3863.04, z=33.28, from=2000, to=2200},
}
