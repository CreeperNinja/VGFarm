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

util.AddNetworkString("SendLimitData")

-- Set the limit when the player joins
hook.Add("PlayerInitialSpawn", "SetPlayerLimit", function(ply)
    net.Start("SendLimitData")
        net.WriteInt(baseItemLimitTable["Pots"], 16)
        net.WriteInt(baseItemLimitTable["Gardens"], 16)
        net.WriteInt(baseItemLimitTable["Seeds"], 16)
    net.Send(ply)
end)

