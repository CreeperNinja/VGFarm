AddCSLuaFile("sh_vgfarm.lua")
local VGFarm = include("sh_vgfarm.lua")

//Locolized Methods
local random = math.random
local print = print
local WriteUInt = net.WriteUInt
local WriteString = net.WriteString
local Send = net.Send
local Broadcast = net.Broadcast

//Bit Size For Sending int values
local intBit = 16

// how freuquent the market updates are in seconds
local marketUpdateFrequency = 5

local eachMarketSize = VGFarm.EachMarketSize

//Data used for UI and pricing in this format ["Name"] {priceValue1, priceValue2, priceValue3...}
local markets = VGFarm.CropMarkets

local baseItemLimitTable = 
{
    ["Pots"] = 10,
    ["Gardens"] = 6,
    ["Seeds"] = 20  
}

local totalMarkets = table.Count(markets)

//Removes The Left Most Value And puts a new one at the Right most side
local function ReplaceOldValue(marketData, value)
    //if !IsValid(value) then print("Replacing Value Faild! | invalid value: "..value) return end
    table.remove(marketData, 1)
    marketData[eachMarketSize] = value 
    
end

local function ReplaceEachOldMarketDataValue(initialMin, initialMax)
    for marketName, marketData in pairs(markets) do
        ReplaceOldValue(marketData, random(initialMin, initialMax))
    end
end

//Hooks for Networking

util.AddNetworkString("SendPlayerData")

-- Sets Up Info When Player First Spawns In - Set the limit when the player joins
hook.Add("PlayerInitialSpawn", "SetPlayerData", function(ply)

    net.Start("SendPlayerData")
    WriteUInt(baseItemLimitTable["Pots"], 16)
    WriteUInt(baseItemLimitTable["Gardens"], 16)
    WriteUInt(baseItemLimitTable["Seeds"], 16)
    Send(ply)
end)

util.AddNetworkString("SendMarketData")

// Sends All market tables values
function SendAllMarketData(ply)
    net.Start("SendMarketData")
    print("Sending Marked Data : Total Markets - "..totalMarkets.." | Market Size - "..eachMarketSize)
    WriteUInt(intBit, 6)
    for marketName, marketData in pairs(markets) do
        WriteString(marketName)
        for key, value in ipairs(marketData) do
            WriteUInt(value, intBit)
        end
        print("Sent Market "..marketName.." With Final Value Of "..marketData[eachMarketSize])
    end
    Send(ply)
end

//Sends All Market Values when player first spawns
hook.Add("PlayerInitialSpawn", "SetMarketDataInfo", function(ply)
    SendAllMarketData(ply)
end)

util.AddNetworkString("SendNewMarketDataValues")

//Sends New Market Values To Specific Player
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

//Sends New Market Values To All Players
function SendNewMarketValuesToAll()
    net.Start("SendNewMarketDataValues")
    WriteUInt(intBit, 6)
    for marketName, marketData in pairs(markets) do
        //print("Sending ".. marketName)
        print("Sent new "..marketName.." values "..marketData[eachMarketSize])
        WriteString(marketName)
        WriteUInt(marketData[eachMarketSize], intBit)
    end
    Broadcast()
end

// Update Market Values every minute
timer.Create("UpdateMarketDataEveryMinute", marketUpdateFrequency, 0, function()
    ReplaceEachOldMarketDataValue(1, 100)    
    SendNewMarketValuesToAll()
end)

//Removes Player Position From The Cache
hook.Add("PlayerDisconnected", "CleanupPositionCache", function(ply)
    playersPosition[ply:SteamID64()] = nil
    print(ply:Name().. " has left the server. " )
    print("Removed "..ply:Nick().."\'s Position Cache")
end)
    

