if CLIENT then
	print( "myaddon Client Script Loaded!" )
end

local function SetLimitDataFromServer()
    itemLimitTable["Pots"] = net.ReadInt(16)
    itemLimitTable["Gardens"] = net.ReadInt(16)
    itemLimitTable["Seeds"] = net.ReadInt(16)
end

net.Receive("SendLimitData", SetLimitDataFromServer)

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
    ["Pots"] = 0,
    ["Gardens"] = 0,
    ["Seeds"] = 0  
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

hook.Add( "PlayerButtonDown", "PurchaseSeeds", function( ply, button )
	if button != KEY_T then return end

	if CLIENT and not IsFirstTimePredicted() then return end

    AddToInventory("Seeds", 5)

end)

hook.Add( "PlayerButtonDown", "PurchasePots", function( ply, button )
	if button != KEY_O then return end

	if CLIENT and not IsFirstTimePredicted() then return end

    AddToInventory("Pots", 1)
end)

hook.Add( "PlayerButtonDown", "RemoveSeeds", function( ply, button )
	if button != KEY_H then return end

	if CLIENT and not IsFirstTimePredicted() then return end

    RemoveFromInventory("Seeds", 1)
end)
