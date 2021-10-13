-- An npc drives with the car to your job start location (not sure if works for long range, its more for fun)
aiEnabled = false

-- You should replace these custom vehicles if your server does not have them
vehicles = {
    {model="rs7", name="Audi RS7"},
    {model="f82", name="BMW M5"},
    {model="m6f13", name="BMW M6 F13"},
    {model="bmwe39", name="BMW E39"},
    {model="subwrx", name="Subaru Impreza WRX STI 2004"},
}

-- Locations where the vehicles spawn
spawns = {
    {name="Rancho", heading=302.58, x=548.79, y=-1930.65, z=24.25},
    {name="Cypress flats", heading=179.45, x=998.85, y=-1944.38, z=30.47},
    {name="La mesa inside a garage", heading=263.13, x=946.4, y=-1697.76, z=29.52}
}

-- Delivery locations for stolen vehicles
-- From - to is the range of the payout for delivering the vehicle
destinations = {
    {name="Pacific bluffs garage", x=-2011.74, y=-351.87, z=47.69, from=1200, to=1400},
    {name="Chumash house parking lot", x=-3201.59, y=1152.77, z=9.24, from=1500, to=1700},
    {name="Vineyard parking lot", x=-1921.22, y=2044.75, z=140.32, from=1800, to=2000},
    {name="Sandyshores trailer park", x=1828.54, y=3863.04, z=33.28, from=2000, to=2200}
}
