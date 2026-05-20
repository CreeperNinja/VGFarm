## Planter Hooks

**Realm:** Server

```lua
-- runs after crops are created and assigned to the cropHolder.
hook.Run("VGFarm_CropsSpawned", planter, cropsTable, cropHolder)
```

**Returns:** None  
Returning a value will stop other hooks from running.

`Entity planter` = planter that grew the crops

`table cropsTable` = formatted as the name of the crop as index and an int amount as the key | when a potato finishes growing it will be `["Potato"] = 1`

`Entity cropHolder` = the entity that holds the crop list values in it to be collected by the player

Example:
```lua
hook.Add("VGFarm_CropsSpawned", "Example", function(planter, cropsTable, cropHolder)
    print(planter:GetClass().. " Has Grown Crops And Placed It In "..cropHolder:GetClass())
    for cropName, cropAmount in pairs(cropsTable) do
        print(cropName..": "..cropAmount)
    end
end)
```

## Market Hooks

**Realm:** Server

```lua
-- runs after new market values are set.
hook.Run("VGFarm_MarketUpdated", newMarketValuesTable)
```

**Returns:** None  
Returning a value will stop other hooks from running.

`newMarketValuesTable` = table of only the newest values in the market

Example:
```lua
hook.Add("VGFarm_MarketUpdated", "Example", function(newMarketValuesTable)
    print("Market Has Updated With New Values!")
    for cropName, cropValue in pairs(newMarketValuesTable) do
        print(cropName..": "..cropValue)
    end
end)
```

#

**Realm:** Server

```lua
-- runs after a player has sold a crop
hook.Run("VGFarm_SoldCrop", ply, cropName, amount, price, earnings)
```

**Returns:** None  
Returning a value will stop other hooks from running.

`Player ply` = player that sold the crop

`string cropName` = name of the sold crop

`int amount` = amount of that crop that was sold

`float price` = price of the crop when sold

`float earnings` = amount of currency gained from the sell action

Example:
```lua
hook.Add("VGFarm_SoldCrop", "Example", function(ply, cropName, amount, price, earnings)
    print(ply:Nick().." sold "..amount.." "..cropName.." for "..earnings.."$ ("..price.."$ each)")
end)
```

#

**Realm:** Server

```lua
-- runs after the player has sold all crops
hook.Run("VGFarm_SoldAllCrops", ply, sellStatsTable, totalEarnings)
```

**Returns:** None  
Returning a value will stop other hooks from running.

`Player ply` = player that sold the crop

`table sellStatsTable` = a hashmap of selling stats Example:

```lua
sellStatsTable = {
    ["Carrots"] = {amount = 12, price = 5, earning = 60},
    ["Potatoes"] = {amount = 10, price = 8, earning = 80}
}
```

`float totalEarnings` = total amount of currency earned from selling all the crops 

Example:
```lua
hook.Add("VGFarm_SoldAllCrops", "Example", function(ply, sellStatsTable, totalEarnings)
    print(ply:Nick().." Sold Crops for a total of "..totalEarnings..":\n")
    for cropName, sellStat in pairs(sellStatsTable) do
        print(cropName..": "..sellStat.amount.." | price: "..sellStat.price.." | earning: "..sellStat.earning)
    end
end)
```

## Crop Hooks

**Realm:** Server

```lua
-- runs before a player collects the crops
hook.Run("VGFarm_CanCollectCrops", ply, cropHolder, cropsTable)
```

**Returns:**
- `false` to block the action
- `nil` to allow (default)

`Player ply` = player that tried to collect the crops

`Entity cropHolder` = entity containing the crops

`table cropsTable` = table of all the stored crops

Example:
```lua
hook.Add("VGFarm_CanCollectCrops", "NoPotatoesAllowed", function(ply, cropEnt, crops)
    if crops["Potatoes"] then
        print("No Potatoes Allowed!")
        return false
    end
end)
```

#

**Realm:** Server

```lua
-- runs after a player collected the crops
hook.Run("VGFarm_CollectedCrops", ply, cropHolder, cropsTable)
```

**Returns:** None  
Returning a value will stop other hooks from running.

`Player ply` = player that collect the crops

`Entity cropHolder` = entity containing the crops

`table cropsTable` = table of all the stored crops

Example:
```lua
hook.Add("VGFarm_CollectedCrops", "Example", function(ply, cropHolder, cropsTable)
    print(ply:Nick().." Has Collected Crops:")
    for cropName, cropAmount in pairs(cropsTable) do
        print(cropName..": "..cropAmount)
    end
end)
```
