local VGFarmUtils = include("autorun/vgfarm_utils.lua")

//Localized Function
local random = math.random

local CurrentGamemode = engine.ActiveGamemode()

print("Running Mode: "..CurrentGamemode)

local VGFarm = {}

VGFarm.MaxCropPriceMultiplier = 10

VGFarm.CropValueChangeMultiplier = 0.5

//How freuquent the market updates are in seconds
VGFarm.marketUpdateFrequency = 5

//min 2, 1 for effect and another for value
VGFarm.EachMarketSize = 20

VGFarm.LoadPlayerInventoryFromDatabase = false 

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
    for i = 1, VGFarm.EachMarketSize - 1 do
        market[i] = 0
    end
    market[VGFarm.EachMarketSize] = crop.baseMarketPrice
    return market
end

VGFarm.CropsIDs = {}

for key, crop in ipairs(VGFarm.Crops) do
    VGFarm.CropsIDs[crop.name] = key
end

VGFarm.CropBitEncoder = VGFarmUtils.GetOptimizedBitSize(#VGFarm.Crops)

VGFarm.CropMarkets = {}

for key, crop in ipairs(VGFarm.Crops) do
    VGFarm.CropMarkets[crop.name] = GenerateCropMarket(crop)
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
    return oldValue + cropBasePrice * (VGFarm.CropValueChangeMultiplier * changeDirection)
end

function VGFarm.CreateNewCropValue(cropName, oldValue)
    local cropBasePrice = VGFarm.Crops[VGFarm.CropsIDs[cropName]].baseMarketPrice
    local newPrice = CreateNewCropPrice(oldValue, cropBasePrice)

    local maxPrice = cropBasePrice * VGFarm.MaxCropPriceMultiplier
    if newPrice <= cropBasePrice or newPrice >= maxPrice then 
        --print("\r\n["..cropName.."] Recalculated New Price Because Current Price Is: "..newPrice)
        newPrice = CreateNewCropPrice(oldValue, cropBasePrice) 
        --print("New Price "..newPrice.."\r\n")
    end
    return math.Clamp(newPrice, cropBasePrice, cropBasePrice * VGFarm.MaxCropPriceMultiplier)
end

function VGFarm.AddMoney(ply, amount)
    if  CurrentGamemode == "darkrp" and ply.addMoney then
        ply:addMoney(amount)
        DarkRP.notify(ply, 0, 8, "You received $" .. amount .. " for selling crops.")
    end
end


return VGFarm
