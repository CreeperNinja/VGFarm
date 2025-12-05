VGFarmConfig = VGFArmConfig or {}

--Planter
VGFarmConfig.planterUpdateSpeed = 5 --The Speed in Seconds Which The Planter Growth, Drain And Network Massages Are Sent (Growth And Drain Speed Is Multiplied By The Update Speed Internally)
VGFarmConfig.waterDrainAmount = 1 --Amount Of Water That Is Drained From The Planter Times The Update Speed
VGFarmConfig.plantGrowthAmount = 1--Amount Of Growth That A Plant Recieves Times The Update Speed

--Market
VGFarmConfig.marketUpdateFrequency = 20 --How Many Seconds It Takes For The Market To Change
VGFarmConfig.maxMarketMultiplier = 10 --Max Price From A base Amount --> (10 mult) base 2$ = max 20$
VGFarmConfig.marketMultiplierChange = 0.5 --The Price Change Each Market Update (Can Go Up, Down, Or Stay The Same)
VGFarmConfig.eachMarketSize = 20 --Min 2 Required --> 1 is always used to make a line to the y axis and another is needed to display a value on the grid (Requires Server Restart)

VGFarmConfig.Crops =
{
    { name = "Carrots",      baseMarketPrice = 1},
    { name = "Potatos",      baseMarketPrice = 2},
    { name = "Cucumbers",    baseMarketPrice = 3},
    { name = "Tomatoes",     baseMarketPrice = 4},
    { name = "Lettuce",      baseMarketPrice = 5},
    { name = "Onions",       baseMarketPrice = 6},
    { name = "Beets",        baseMarketPrice = 7},
    { name = "Spinachs",     baseMarketPrice = 8},
    { name = "Eggplants",    baseMarketPrice = 9},
    { name = "Bell Peppers", baseMarketPrice = 10},
    { name = "Test Crop", baseMarketPrice = 100}
}

--Inventory
VGFarmConfig.loadPlayerInventoryFromDatabase = false --Currently Not Supported

return VGFarmConfig