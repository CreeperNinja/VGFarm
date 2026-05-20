local VGFarmUtils = include("autorun/vgfarm_utils.lua")

//Localized Function
local random = math.random

local CurrentGamemode = engine.ActiveGamemode()

local VGFarm = VGFarm or {}

local function GenerateCropMarket(crop)
    local market = {}
    for i = 1, VGFarmConfig.eachMarketSize - 1 do
        market[i] = 0
    end
    market[VGFarmConfig.eachMarketSize] = crop.baseMarketPrice
    return market
end

local function CreateCropsIDs()
    VGFarm.CropsIDs = {}

    for key, crop in ipairs(VGFarmConfig.Crops) do
        VGFarm.CropsIDs[crop.name] = key
    end
end

local function CreateCropMarket()
    VGFarm.CropMarkets = {}
    VGFarm.CropMarketsCount = 0
    
    for key, crop in ipairs(VGFarmConfig.Crops) do
        VGFarm.CropMarkets[crop.name] = GenerateCropMarket(crop)
        VGFarm.CropMarketsCount = VGFarm.CropMarketsCount + 1
    end
end

local function CreateCropBitEncoder()
    VGFarm.CropBitEncoder = VGFarmUtils.GetOptimizedBitSize(VGFarm.CropMarketsCount)
end

function CreateCropData()
    CreateCropsIDs()
    CreateCropMarket()
    CreateCropBitEncoder()
end

CreateCropData()

--Strictly used to write crop info efficiently
function VGFarm.SmartNetCropWrite(cropName)
    net.WriteUInt(VGFarm.CropsIDs[cropName], VGFarm.CropBitEncoder)
end

--Strictly used to read crop info efficiently
function VGFarm.SmartNetCropRead()
    return VGFarmConfig.Crops[net.ReadUInt(VGFarm.CropBitEncoder)].name
end

local function CreateNewCropPrice(oldValue, cropBasePrice)
    local changeDirection = random(-1, 1)
    return oldValue + cropBasePrice * (VGFarmConfig.marketMultiplierChange * changeDirection)
end

function VGFarm.CreateNewCropValue(cropName, oldValue)
    local cropBasePrice = VGFarmConfig.Crops[VGFarm.CropsIDs[cropName]].baseMarketPrice
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
