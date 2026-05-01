AddCSLuaFile("sh_vgfarm.lua")
local VGFarm = include("sh_vgfarm.lua")

SVGFarm = SVGFarm or {}

//Localized Functions
local random = math.random
local print = print
local WriteUInt = net.WriteUInt
local WriteString = net.WriteString
local NetStart = net.Start
local Send = net.Send
local Broadcast = net.Broadcast

//Holds inventory data of all the players
local PlayerInventories = PlayerInventories or {} -- Start with an empty table

local eachMarketSize = VGFarmConfig.eachMarketSize

//Data used for UI and pricing in this format ["Name"] {priceValue1, priceValue2, priceValue3...}
local markets = VGFarm.CropMarkets
local totalMarkets = VGFarm.CropMarketsCount

local lastSavedUpdateFrequency = VGFarmConfig.marketUpdateFrequency

//Network Strings
util.AddNetworkString("RequestSellCrop")
util.AddNetworkString("RequestSellAllCrops")
util.AddNetworkString("ResetPlayerInventory")
util.AddNetworkString("ResetCropInPlayerInventory")
util.AddNetworkString("SendPlayerInventoryCrop")
util.AddNetworkString("SendPlayerInventoryCrops")
util.AddNetworkString("SendPlayerData")
util.AddNetworkString("SendMarketData")
util.AddNetworkString("SendNewMarketDataValues")

-- Market Functions
--Removes The Left Most Value And puts a new one at the Right most side
local function ReplaceOldValue(marketData, value)
    //if !IsValid(value) then print("Replacing Value Faild! | invalid value: "..value) return end
    table.remove(marketData, 1)
    marketData[eachMarketSize] = value 
    
end

local function ReplaceEachOldMarketDataValue()
    local statIndex = 0
    local newMarketStatTable = {}
    for marketName, marketData in pairs(markets) do
        statIndex = statIndex + 1
        local newValue = VGFarm.CreateNewCropValue(marketName, marketData[eachMarketSize])
        ReplaceOldValue(marketData, newValue)
        newMarketStatTable[marketName] = newValue
    end
    return newMarketStatTable
end

function SendAllMarketData(ply)
    net.Start("SendMarketData")
    print("Sending Market Data to \""..ply:Nick().."\" : Total Markets - "..totalMarkets.." | Market Size - "..eachMarketSize)
    for marketName, marketData in pairs(markets) do
        VGFarm.SmartNetCropWrite(marketName)
        for key, value in ipairs(marketData) do
            VGFarmUtils.SmartNetFloatToIntWrite(value)
        end
    end
    Send(ply)
end

--Sends New Market Values To All Players
function SendNewMarketValuesToAll()
    net.Start("SendNewMarketDataValues")
    for marketName, marketData in pairs(markets) do
        VGFarm.SmartNetCropWrite(marketName)
        VGFarmUtils.SmartNetFloatToIntWrite(marketData[eachMarketSize])
    end
    Broadcast()
end

-- Player Functions
local function SetInitialPlayerInventory(ply)
    PlayerInventories[ply] = {} -- Start with an empty table
    
    //Sends Data To Client if True
    if VGFarm.LoadPlayerInventoryFromDatabase then
        -- net.Start("SendPlayerData")
        -- WriteUInt(#VGFarm.Crops, 4)

        -- for key, crop in ipairs(VGFarm.Crops) do
        --     PlayerInventories[ply][crop.name] = 0
        --     WriteUInt(VGFarm.CropsIDs[crop.name], 4)
        -- end

        -- Send(ply)
        print("[Warning] Currently Not Actually Uses DB values to send data, sends 0's to all types")
        -- return -- Avoids running default setup below
    end

    //Sets each crop amount in inventory to 0
    for key, crop in ipairs(VGFarm.Crops) do
        PlayerInventories[ply][crop.name] = 0
    end
end

-- Currently not in use
function SVGFarm:AddCropToPlayerInventory(ply, cropName, amount)
    if not IsValid(ply) or PlayerInventories[ply][cropName] == nil then print("Invalid Player Or Crop, Cannot Add To Inventory") return end

    PlayerInventories[ply][cropName] = PlayerInventories[ply][cropName] + amount
    local cropAmount = PlayerInventories[ply][cropName]
    print("Added To Inventory Now Player Has "..PlayerInventories[ply][cropName].." "..cropName)

    NetStart("SendPlayerInventoryCrop")
    VGFarm.SmartNetCropWrite(cropName)
    VGFarmUtils.SmartNetUIntWrite(cropAmount)

    Send(ply)
end

-- Currently used instead of its singular version avove
function SVGFarm:AddCropsToPlayerInventory(ply, cropsHashMap)
    NetStart("SendPlayerInventoryCrops")
    WriteUInt(table.Count(cropsHashMap), VGFarm.CropBitEncoder)

    for cropName, amount in pairs(cropsHashMap) do
        PlayerInventories[ply][cropName] = PlayerInventories[ply][cropName] + amount
        local cropAmount = PlayerInventories[ply][cropName]
        VGFarmUtils.SmartPrint(ply:Nick().." Now has "..cropAmount.." "..cropName)
        
        --Sends crop data
        VGFarm.SmartNetCropWrite(cropName)
        VGFarmUtils.SmartNetUIntWrite(cropAmount)
    end
    Send(ply)
end


local function ResetPlayerInventory(ply)
    NetStart("ResetPlayerInventory")
    Send(ply)
end

function SVGFarm:SellAllCrops(ply)
    local totalEarnings = 0
    local Inventory = PlayerInventories[ply]
    local sellStats = {}

    for cropName, cropAmount in pairs(Inventory) do
        if cropAmount == 0 then continue end
        local marketPrice = markets[cropName][eachMarketSize]
        local cropEarning = cropAmount * marketPrice
        totalEarnings = totalEarnings + cropEarning
        sellStats[cropName] = {amount = cropAmount, price = marketPrice, earning = cropEarning}
        Inventory[cropName] = 0
    end

    if totalEarnings == 0 then ply:ChatPrint("No Crops To Sell") return end
    ply:ChatPrint("Sold All Inventory ($"..totalEarnings..")")
    VGFarm.AddMoney(ply, totalEarnings)
    ResetPlayerInventory(ply)

    -- passes parameters when a player sells all crops in the market
    hook.Run("VGFarm_SoldAllCrops", ply, sellStats, totalEarnings)

    return totalEarnings
end

--Sends an crop to set its value to 0
local function ResetCropInPlayerInventory(ply, cropName)
    NetStart("ResetCropInPlayerInventory")
    VGFarm.SmartNetCropWrite(cropName)
    Send(ply)
end

function SVGFarm:SellCrop(ply, cropName)
    local Inventory = PlayerInventories[ply]

    local cropAmount = Inventory[cropName]

    if cropAmount == 0 then VGFarmUtils.SmartPrint("No "..cropName.." To Sell") return end

    local marketPrice = markets[cropName][eachMarketSize]

    local totalEarnings = cropAmount * marketPrice

    ply:ChatPrint("You sold "..cropAmount.."x ".. cropName.." for $"..totalEarnings.." ("..marketPrice.."$ each)")
    VGFarm.AddMoney(ply, totalEarnings)
    PlayerInventories[ply][cropName] = 0

    ResetCropInPlayerInventory(ply, cropName)
    hook.Run("VGFarm_SoldCrop", ply, cropName, cropAmount, marketPrice, totalEarnings)
end


-- Network Recievs
net.Receive("RequestSellCrop", function(len, ply)
    local cropName = VGFarm.SmartNetCropRead()
    local inventory = PlayerInventories[ply]

    if inventory[cropName] == 0 then return end

    SVGFarm:SellCrop(ply, cropName)
end)

net.Receive("RequestSellAllCrops", function(len, ply)
    SVGFarm:SellAllCrops(ply)
end)

-- Hooks
-- Sets Up Info When Player First Spawns In
hook.Add("PlayerInitialSpawn", "VGFarm_SetPlayerData", function(ply)
    SetInitialPlayerInventory(ply)
    SendAllMarketData(ply)
end)

//Removes Player Data
hook.Add("PlayerDisconnected", "VGFarm_CleanupPositionCache", function(ply)
    PlayerInventories[ply] = nil  -- Remove inventory data
    print(ply:Name().. " has left the server. \nData Removed")
end)

-- Timers
local function UpdateMarket()
    local marketUpdateFrequency = VGFarmConfig.marketUpdateFrequency
    if lastSavedUpdateFrequency ~= marketUpdateFrequency then
        lastSavedUpdateFrequency = marketUpdateFrequency
        timer.Adjust("UpdateMarketData", marketUpdateFrequency, 0, UpdateMarket)
        return 
    end
    local newMarketValuesTable = ReplaceEachOldMarketDataValue()    
    SendNewMarketValuesToAll()
    hook.Run("VGFarm_MarketUpdated", newMarketValuesTable)

end

-- Update Market Values
timer.Create("UpdateMarketData", VGFarmConfig.marketUpdateFrequency, 0, UpdateMarket)

hook.Add("VGFarm_SoldAllCrops", "Example", function(ply, sellStatsTable, totalEarnings)
    print(ply:Nick().." Sold Crops for a total of "..totalEarnings..":\n")
    for cropName, sellStat in pairs(sellStatsTable) do
        print(cropName..": "..sellStat.amount.." | price: "..sellStat.price.." | earning: "..sellStat.earning)
    end
end)

concommand.Add("vgfarm_debug_add_crops", function(ply, cmd, args)
    local amount = tonumber(args[1])

    if not amount then
        print("Invalid number")
        return
    end

    local Inventory = PlayerInventories[ply]
    for cropName, cropAmount in pairs(Inventory) do
        PlayerInventories[ply][cropName] = cropAmount + amount
    end
end)

return SVGFarm
