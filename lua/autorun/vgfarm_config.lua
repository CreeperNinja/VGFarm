VGFarmConfig = VGFArmConfig or {}

--Market
VGFarmConfig.marketUpdateFrequency = 20 --How Many Seconds It Takes For The Market To Change
VGFarmConfig.maxMarketMultiplier = 10 --Max Price From A base Amount --> (10 mult) base 2$ = max 20$
VGFarmConfig.marketMultiplierChange = 0.5 --The Price Change Each Market Update (Can Go Up, Down, Or Stay The Same)
VGFarmConfig.eachMarketSize = 20 --Min 2 Required --> 1 is always used to make a line to the y axis and another is needed to display a value on the grid (Requires Server Restart)

--Inventory
VGFarmConfig.loadPlayerInventoryFromDatabase = false --Currently Not Supported

return VGFarmConfig