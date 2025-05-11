
//Localized Function
local random = math.random

//Generates A table of values to be used for a market
local function GenerateMarket(initialMin, initialMax)
    local market = {}
    for i = 1, VGFarm.EachMarketSize-1 do
        market[i] = 0
    end
    market[VGFarm.EachMarketSize] = random(initialMin, initialMax)
    return market
end

local VGFarm = {}

//min 2, 1 for effect and another for value
VGFarm.EachMarketSize = 20

VGFarm.CropMarkets = 
{    
    ["Carrots"] =       GenerateMarket(0, 100),
    ["Potatos"] =       GenerateMarket(0, 100),
    ["Cucumbers"] =     GenerateMarket(0, 100),
    ["Tomatoes"] =      GenerateMarket(0, 100),
    ["Lettuce"] =       GenerateMarket(0, 100),
    ["Onions"] =        GenerateMarket(0, 100),
    ["Beets"] =         GenerateMarket(0, 100),
    ["Spinachs"] =       GenerateMarket(0, 100),
    ["Eggplants"] =      GenerateMarket(0, 100),
    ["Bell Peppers"] =  GenerateMarket(0, 100)
}

return VGFarm
