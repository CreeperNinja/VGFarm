
// min 2 - 1 for effect and another for value
eachMarketSize = 20

local intBit = 16

// how freuquent the market updates are in seconds
local marketUpdateFrequency = 60

function GenerateMarket(initialMin, initialMax)
    local market = {}
    for i = 1, eachMarketSize-1 do
        market[i] = 0
    end
    market[eachMarketSize] = math.random(initialMin, initialMax)
    print("Generated Market With Values: "..market[eachMarketSize])
    return market
end

markets = 
{    
    ["Carrots"] = GenerateMarket(1, 100),
    ["Potatos"] = GenerateMarket(1, 100),
    ["Cucumbers"] = GenerateMarket(1, 100),
    ["Tomatoes"] = GenerateMarket(1, 100),
    ["Lettuce"] = GenerateMarket(1, 100),
    ["Onions"] = GenerateMarket(1, 100),
    ["Beets"] = GenerateMarket(1, 100),
    ["Spinach"] = GenerateMarket(1, 100),
    ["Eggplant"] = GenerateMarket(1, 100),
    ["Bell Peppers"] = GenerateMarket(1, 100)
}

//Removes The Left Most Value And puts a new one at the Right most side
function ReplaceOldValue(marketData, value)
    //if !IsValid(value) then print("Replacing Value Faild! | invalid value: "..value) return end
    table.remove(marketData, 1)
    marketData[eachMarketSize] = value 
end

function ReplaceEachOldMarketDataValue(initialMin, initialMax)
    for marketName, marketData in pairs(markets) do
        ReplaceOldValue(marketData, math.random(initialMin, initialMax))
    end
end

unlocksAtLevel = {}

upgradesAtLevelTable = {}

upgradesPerLevelTable = 
{
    ["SeedLimitIncress"] = 2,
}

baseItemLimitTable = 
{
    ["Pots"] = 10,
    ["Gardens"] = 6,
    ["Seeds"] = 20  
}

local targetJobName = "Farmer"

util.AddNetworkString("SendPlayerData")

-- Set the limit when the player joins
hook.Add("PlayerInitialSpawn", "SetPlayerData", function(ply)
    net.Start("SendPlayerData")
        net.WriteInt(baseItemLimitTable["Pots"], 16)
        net.WriteInt(baseItemLimitTable["Gardens"], 16)
        net.WriteInt(baseItemLimitTable["Seeds"], 16)
    net.Send(ply)
end)

util.AddNetworkString("SendMarketData")

// Sends All market tables values
function SendMarketDataToFarmer(ply)
    net.Start("SendMarketData")
    net.WriteUInt(table.Count(markets), 8)
    net.WriteUInt(eachMarketSize, 8)
    print("Sending Marked Data : Total Markets - "..table.Count(markets).." | Market Size - "..eachMarketSize)
    net.WriteUInt(intBit, 6)
    for marketName, marketData in pairs(markets) do
        net.WriteString(marketName)
        for key, value in ipairs(marketData) do
            net.WriteUInt(value, intBit)
        end
        print("Sent Market "..marketName.." With Final Value Of "..marketData[eachMarketSize])
    end
    net.Send(ply)
end

-- Set the limit when the player joins
hook.Add("PlayerInitialSpawn", "SetMarketDataInfo", function(ply)
    SendMarketDataToFarmer(ply)
end)

util.AddNetworkString("SendNewMarketDataValues")

function SendNewMarketValues(ply)
    net.Start("SendNewMarketDataValues")
    net.WriteUInt(table.Count(markets), 8)
    net.WriteUInt(intBit, 6)
    for marketName, marketData in pairs(markets) do
        //print("Sending ".. marketName)
        print("Sent new "..marketName.." values "..marketData[eachMarketSize])
        net.WriteString(marketName)
        net.WriteUInt(marketData[eachMarketSize], intBit)
    end
    net.Send(ply)
end

// Update Market Values every minute
timer.Create("UpdateMarketDataEveryMinute", marketUpdateFrequency, 0, function()
    ReplaceEachOldMarketDataValue(1, 100)    
    for key, ply in ipairs(player.GetAll()) do
        // use this when teams are set up in the game and only Farmers can view, other wise everyone can view
        //if ply:getJobTable() and ply:getJobTable().name == targetJobName then SendMarketDataToFarmer(ply) end
        SendNewMarketValues(ply) //remove this when using teams
    end
end)

//left to do - send player inventory data or atleast make the inventory depend on all the market crop types

