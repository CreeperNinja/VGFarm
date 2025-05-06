if CLIENT then
	print( "myaddon Client Script Loaded!" )
end

local function SetLimitDataFromServer()
    itemLimitTable["Pots"] = net.ReadInt(16)
    itemLimitTable["Gardens"] = net.ReadInt(16)
    itemLimitTable["Seeds"] = net.ReadInt(16)
end

net.Receive("SendPlayerData", SetLimitDataFromServer)

//Skill Level Of The Farming Job
farmingLevel = 1


//Current Limit of Items
itemLimitTable = itemLimitTable or 
{  
    ["Pots"] = 0,
    ["Gardens"] = 0,
    ["Seeds"] = 0  
}

//Temporary inventory for testing
playerInventory = 
{    
    ["Carrots"] = 0,
    ["Potatos"] = 0,
    ["Cucumbers"] = 0,
    ["Tomatoes"] = 0,
    ["Lettuce"] = 0,
    ["Onions"] = 0,
    ["Beets"] = 0,
    ["Spinach"] = 0,
    ["Eggplant"] = 0,
    ["Bell Peppers"] = 0
}

function ItemExists(itemName)
    if type(itemName) ~= "string" then print("ItemExists: invalid or missing item name") return false end
    if playerInventory[itemName] != nil then return true end
    print(itemName.." Is Not A Valid Item")
    return false
end

function AddToInventory(itemName, amount)
    //If item name is not in collection then exit
    if !ItemExists(itemName) then return end

    local allowedLimit = ReturnAllowedPurchaseAmount(itemName)
    
    //If  allowed purchace amount is 0 (or less) then exit
    if(allowedLimit <= 0) then return end

    amountToAdd = ReturnFinalAmount(allowedLimit, amount)

    playerInventory[itemName] = playerInventory[itemName] + amountToAdd

    print("Added "..amountToAdd.." "..itemName)

end

//Returns the amount based on the limit and how much requested
function ReturnFinalAmount(allowedLimit, amount)
    if (allowedLimit < amount) then return allowedLimit end
    return amount
end

//Returns the Amount of the Item the player can still buy
function ReturnAllowedPurchaseAmount(itemName)
    if !IsValid(itemLimitTable[itemName]) then print("No Purchase Limit For "..itemName) return 100 end
    if (itemLimitTable[itemName] <= playerInventory[itemName]) then print("Purchase Limit Reached for "..itemName.."("..itemLimitTable[itemName]..")") return 0 end
    return itemLimitTable[itemName] - playerInventory[itemName]
end

//Returns the Amount of the Item the player can remove
function ReturnAllowedRemoveAmount(itemName)
    if (playerInventory[itemName] <= 0) then print("Remove Limit Reached for "..itemName) return 0 end
    return playerInventory[itemName]
end

function RemoveFromInventory(itemName, amount)
    //If item name is not in collection then exit
    if !ItemExists(itemName) then return end
    
    local allowedLimit = ReturnAllowedRemoveAmount(itemName)
    
    //If allowed remove amount is 0 (or less) then exit
    if(allowedLimit <= 0) then return end

    amountToRemove = ReturnFinalAmount(allowedLimit, amount)

    playerInventory[itemName] = playerInventory[itemName] - amountToRemove

    print("Removed "..amountToRemove.." "..itemName)
    
    hook.Call("OnPlayerRemovedItem", GAMEMODE, ply, itemName, amountToRemove)

end

function SellAllCrops()
    earnings = 0
    //if !IsValid(playerInventory) then print("No Inventory Set") return end
    for key, value in pairs(playerInventory) do
        playerInventory[key] = 0
        earnings = earnings + value * markets[key][eachMarketSize]
    end
    if earnings == 0 then print("Nothing To Sell") return end
    print("Sold All Inventory ($"..earnings..")")
    return earnings
end

function SellAll(cropname)
    local earnings = 0
    earnings = earnings + playerInventory[cropname] * markets[cropname][eachMarketSize]
    if earnings == 0 then print("No "..cropname.." To Sell") return end

    playerInventory[cropname] = 0
    print("Sold All "..cropname.."($"..earnings..")")
end

hook.Add( "PlayerButtonDown", "PurchaseSeeds", function( ply, button )
	if button != KEY_T then return end

	if CLIENT and not IsFirstTimePredicted() then return end

    AddToInventory("Carrots", 5)

end)

hook.Add( "PlayerButtonDown", "PurchasePots", function( ply, button )
	if button != KEY_O then return end

	if CLIENT and not IsFirstTimePredicted() then return end

    AddToInventory("Potatos", 1)
end)

hook.Add( "PlayerButtonDown", "RemoveSeeds", function( ply, button )
	if button != KEY_H then return end

	if CLIENT and not IsFirstTimePredicted() then return end

    RemoveFromInventory("Carrots", 1)
end)
