VGFarmConfig = VGFArmConfig or {}

--Growth
VGFarmConfig.planterUpdateSpeed = 5 --The Speed in Seconds Which The Planter Growth, Drain And Network Massages Are Sent (Growth And Drain Speed Is Multiplied By The Update Speed Internally)
VGFarmConfig.waterDrainAmount = 1 --Amount Of Water That Is Drained From The Planter Times The Update Speed for each crop (if a crop uses 1 water per second and a planter has 6 crops, it will use 6 water per second)
VGFarmConfig.plantGrowthAmount = 5--Amount Of Growth That A Plant Recieves Times The Update Speed (the growth progress that each crop experiences)

--Dirt Bag
VGFarmConfig.DefaultDirtAmount = 18 --each crop harvest consumes a single dirt

--Planters
VGFarmConfig.Planter = {
    planter_large = {MaxWaterAmount = 1200},
    planter_medium = {MaxWaterAmount = 600},
    planter_small = {MaxWaterAmount = 200},
}

--Waters
VGFarmConfig.Water = {
    water_large = {DefaultWaterAmount = 7200, MaxWaterAmount = 7200},
    water_medium = {DefaultWaterAmount = 3600, MaxWaterAmount = 3600},
    water_small = {DefaultWaterAmount = 1200, MaxWaterAmount = 1200},
}

--Market
VGFarmConfig.marketUpdateFrequency = 20 --How Many Seconds It Takes For The Market To Change
VGFarmConfig.maxMarketMultiplier = 10 --Max Price From A base Amount --> (10 mult) base 2$ = max 20$
VGFarmConfig.marketMultiplierChange = 0.5 --The Price Change Each Market Update (Can Go Up, Down, Or Stay The Same)
VGFarmConfig.eachMarketSize = 20 --Min 2 Required --> 1 is always used to make a line to the y axis and another is needed to display a value on the grid (Requires Server Restart)

VGFarmConfig.Crops = --(Requires Server Restart)
{
    { name = "Carrots",         baseMarketPrice = 1},
    { name = "Potatos",         baseMarketPrice = 2},
    { name = "Cucumbers",       baseMarketPrice = 3},
    { name = "Tomatoes",        baseMarketPrice = 4},
    { name = "Lettuce",         baseMarketPrice = 5},
    { name = "Onions",          baseMarketPrice = 6},
    { name = "Strawberries",    baseMarketPrice = 7},
    { name = "Eggplants",       baseMarketPrice = 8},
    { name = "Pumpkins",        baseMarketPrice = 9},
    { name = "Watermelons",     baseMarketPrice = 10},
}

--Inventory
VGFarmConfig.loadPlayerInventoryFromDatabase = false --Currently Not Supported

return VGFarmConfig