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
local PlayerInventories = {} -- Start with an empty table

//Bit Size For Sending int values
local intBit = 16

local eachMarketSize = VGFarm.EachMarketSize

//Data used for UI and pricing in this format ["Name"] {priceValue1, priceValue2, priceValue3...}
local markets = VGFarm.CropMarkets
local totalMarkets = table.Count(markets)

local baseItemLimitTable = 
{
    ["Pots"] = 10,
    ["Gardens"] = 6,
    ["Seeds"] = 20  
}

//Network Strings
util.AddNetworkString("RequestSellCrop")
util.AddNetworkString("RequestSellAllCrops")
util.AddNetworkString("ResetPlayerInventory")
util.AddNetworkString("ResetCropInPlayerInventory")
util.AddNetworkString("SendPlayerInventoryCrop")
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

local function ReplaceEachOldMarketDataValue(initialMin, initialMax)
    for marketName, marketData in pairs(markets) do
        ReplaceOldValue(marketData, VGFarm.CreateNewCropValue(marketName, marketData[eachMarketSize]))
    end
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

--Sends New Market Values To Specific Player
function SendNewMarketValues(ply)
    net.Start("SendNewMarketDataValues")
    WriteUInt(intBit, 6)
    for marketName, marketData in pairs(markets) do
        //print("Sending ".. marketName)
        print("Sent new "..marketName.." values "..marketData[eachMarketSize])
        WriteString(marketName)
        WriteUInt(marketData[eachMarketSize], intBit)
    end
    Send(ply)
end

--Sends New Market Values To All Players
function SendNewMarketValuesToAll()
    net.Start("SendNewMarketDataValues")
    for marketName, marketData in pairs(markets) do
        //print("Sending ".. marketName)
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
        net.Start("SendPlayerData")
        WriteUInt(#VGFarm.Crops, 4)

        for key, crop in ipairs(VGFarm.Crops) do
            PlayerInventories[ply][crop.name] = 0
            WriteUInt(VGFarm.CropsIDs[crop.name], 4)
        end

        Send(ply)
        print("[Warning] Currently Not Actually Uses DB values to send data, sends 0's to all types")
        return -- Avoids running default setup below
    end

    //Sets each crop amount in inventory to 0
    for key, crop in ipairs(VGFarm.Crops) do
        PlayerInventories[ply][crop.name] = 0
    end
end

function SVGFarm:AddCropToInventory(ply, cropName, amount)
    if not IsValid(ply) or PlayerInventories[ply][cropName] == nil then print("Invalid Player Or Crop, Cannot Add To Inventory") return end

    PlayerInventories[ply][cropName] = PlayerInventories[ply][cropName] + amount
    local cropAmount = PlayerInventories[ply][cropName]
    print("Added To Inventory Now Player Has "..PlayerInventories[ply][cropName].." "..cropName)

    NetStart("SendPlayerInventoryCrop")
    WriteUInt(VGFarm.CropsIDs[cropName], VGFarm.CropBitEncoder)

    local smartBit = VGFarmUtils.GetOptimizedBitSize(cropAmount)
    VGFarmUtils.SmartNetBitWrite(smartBit)
    WriteUInt(PlayerInventories[ply][cropName], smartBit)

    Send(ply)
end

function SVGFarm:SellAllCrops(ply)
    local earnings = 0
    local Inventory = PlayerInventories[ply]
    //if !IsValid(Inventory) then print("No Inventory Set") return end

    for key, value in pairs(Inventory) do
        if value == 0 then continue end
        earnings = earnings + value * markets[key][eachMarketSize]
        Inventory[key] = 0
    end

    if earnings == 0 then print("Nothing To Sell") return end
    print("Sold All Inventory ($"..earnings..")")
    ResetPlayerInventory(ply)

    //Adding Money
    //playerMoney = playerMoney + earnings
    return earnings
end

local function ResetCropInPlayerInventory(ply, cropName)
    NetStart("ResetCropInPlayerInventory")
    VGFarm.SmartNetCropWrite(cropName)
    Send(ply)
end

function SVGFarm:SellCrop(ply, cropName)
    local Inventory = PlayerInventories[ply]
    if Inventory[cropName] == 0 then print("No "..cropName.." To Sell") return end
    local earnings = 0
    earnings = earnings + Inventory[cropName] * markets[cropName][eachMarketSize]
    ply:ChatPrint("You sold " .. Inventory[cropName] .. "x " .. cropName .. " for $" .. earnings .. " ("..markets[cropName][eachMarketSize].."$ each)")
    PlayerInventories[ply][cropName] = 0
    ResetCropInPlayerInventory(ply, cropName)
end

local function ResetPlayerInventory(ply)
    NetStart("ResetPlayerInventory")
    Send(ply)
end


-- Network Recievs
-- W.I.P
net.Receive("RequestSellCrop", function(len, ply)
    print( "Message from " .. ply:Nick() .. " received. Its length is " .. len .. "." )

    local cropName = VGFarm.SmartNetCropRead()
    local inventory = PlayerInventories[ply]

    if inventory[cropName] == 0 then return end

    SVGFarm:SellCrop(ply, cropName)
end)

-- Hooks
-- Sets Up Info When Player First Spawns In
hook.Add("PlayerInitialSpawn", "SetPlayerData", function(ply)
    SetInitialPlayerInventory(ply)
    SendAllMarketData(ply)
end)

//Removes Player Data
hook.Add("PlayerDisconnected", "CleanupPositionCache", function(ply)
    PlayerInventories[ply] = nil  -- Remove inventory data
    print(ply:Name().. " has left the server. \r\nData Removed")
end)

-- Timers
// Update Market Values every minute
timer.Create("UpdateMarketDataEveryMinute", VGFarm.marketUpdateFrequency, 0, function()
    ReplaceEachOldMarketDataValue(1, 100)    
    SendNewMarketValuesToAll()
end)

return SVGFarm
