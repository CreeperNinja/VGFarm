local VGFarmUtils = include("autorun/vgfarm_utils.lua")

//Localized Function
local random = math.random

local CurrentGamemode = engine.ActiveGamemode()

local VGFarm = {}

VGFarm.Crops =
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
    { name = "Bell Peppers", baseMarketPrice = 10}
}

local function GenerateCropMarket(crop)
    local market = {}
    for i = 1, VGFarmConfig.eachMarketSize - 1 do
        market[i] = 0
    end
    market[VGFarmConfig.eachMarketSize] = crop.baseMarketPrice
    return market
end

VGFarm.CropsIDs = {}

for key, crop in ipairs(VGFarm.Crops) do
    VGFarm.CropsIDs[crop.name] = key
end

VGFarm.CropBitEncoder = VGFarmUtils.GetOptimizedBitSize(#VGFarm.Crops)

VGFarm.CropMarkets = {}

VGFarm.CropMarketsCount = 0

for key, crop in ipairs(VGFarm.Crops) do
    VGFarm.CropMarkets[crop.name] = GenerateCropMarket(crop)
    VGFarm.CropMarketsCount = VGFarm.CropMarketsCount + 1
end

--Strictly used to write crop info efficiently
function VGFarm.SmartNetCropWrite(cropName)
    net.WriteUInt(VGFarm.CropsIDs[cropName], VGFarm.CropBitEncoder)
end

--Strictly used to read crop info efficiently
function VGFarm.SmartNetCropRead()
    return VGFarm.Crops[net.ReadUInt(VGFarm.CropBitEncoder)].name
end

local function CreateNewCropPrice(oldValue, cropBasePrice)
    local changeDirection = random(-1, 1)
    return oldValue + cropBasePrice * (VGFarmConfig.marketMultiplierChange * changeDirection)
end

function VGFarm.CreateNewCropValue(cropName, oldValue)
    local cropBasePrice = VGFarm.Crops[VGFarm.CropsIDs[cropName]].baseMarketPrice
    local newPrice = CreateNewCropPrice(oldValue, cropBasePrice)

    local maxPrice = cropBasePrice * VGFarmConfig.maxMarketMultiplier
    if newPrice <= cropBasePrice or newPrice >= maxPrice then 
        newPrice = CreateNewCropPrice(oldValue, cropBasePrice) 
    end
    return math.Clamp(newPrice, cropBasePrice, cropBasePrice * VGFarmConfig.maxMarketMultiplier)
end

function VGFarm.AddMoney(ply, amount)
    if  CurrentGamemode == "darkrp" and ply.addMoney then
        ply:addMoney(amount)
        DarkRP.notify(ply, 0, 8, "You received $" .. amount .. " for selling crops.")
    end
end

return VGFarm
