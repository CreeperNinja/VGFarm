local VGFarm = include("sh_vgfarm.lua")

VGFarmPlayer = VGFarmPlayer or {}

//Client Side Inventory For Visuals
VGFarmPlayer.Inventory = {}

//Sets each crop amount in inventory to 0
for key, crop in ipairs(VGFarm.Crops) do
    VGFarmPlayer.Inventory[crop.name] = 0
end

function VGFarmPlayer:GetPlayerFarmInventory()
    return self.Inventory
end

local function SetPlayerData()
    local count = net.ReadUInt(4)

    for i = 1, count do
        local cropName = VGFarm.CropTypes[net.ReadUInt(4)]
        VGFarmPlayer.Inventory[cropName] = 0
    end
end

local function ResetInventory()
    for cropName in pairs(VGFarmPlayer.Inventory) do
        VGFarmPlayer.Inventory[cropName] = 0
    end
end

local function ResetCropInInventory()
    local cropName = VGFarm.SmartNetCropRead()
    VGFarmPlayer.Inventory[cropName] = 0
end

local function SetCropAmount()
    local cropName = VGFarm.Crops[net.ReadUInt(VGFarm.CropBitEncoder)].name
    local smartBit = VGFarmUtils.SmartNetBitRead()
    local cropAmount = net.ReadUInt(smartBit)
    VGFarmPlayer.Inventory[cropName] = cropAmount
end

local function SetCrops()
    local differentCropTypes = net.ReadUInt(VGFarm.CropBitEncoder)
    for i = 1, differentCropTypes do
        local cropName = VGFarm.SmartNetCropRead()
        local cropAmount = VGFarmUtils.SmartNetUIntRead()
        VGFarmPlayer.Inventory[cropName] = cropAmount
    end
end

net.Receive("ResetPlayerInventory", ResetInventory)

net.Receive("ResetCropInPlayerInventory", ResetCropInInventory)

net.Receive("SendPlayerInventoryCrop", SetCropAmount)

net.Receive("SendPlayerInventoryCrops", SetCrops)

net.Receive("SendPlayerData", SetPlayerData)

function VGFarmPlayer:SendSellCropRequest(cropName)
    net.Start("RequestSellCrop")
    print("Attempting to sell "..cropName)
    VGFarm.SmartNetCropWrite(cropName)
    net.SendToServer()
end

function VGFarmPlayer:SendSellAllCropsRequest()
    net.Start("RequestSellAllCrops")
    print("Attempting to sell all crops")
    net.SendToServer()
end

//Returns the amount based on the limit and how much requested -- Deprecated
local function ReturnFinalAmount(allowedLimit, amount)
    if (allowedLimit < amount) then return allowedLimit end
    return amount
end

//Returns the Amount of the Item the player can still buy -- Deprecated
local function ReturnAllowedPurchaseAmount(itemName)
    if !IsValid(itemLimitTable[itemName]) then print("No Purchase Limit For "..itemName) return 100 end
    if (itemLimitTable[itemName] <= Inventory[itemName]) then print("Purchase Limit Reached for "..itemName.."("..itemLimitTable[itemName]..")") return 0 end
    return itemLimitTable[itemName] - Inventory[itemName]
end

//Returns the Amount of the Item the player can remove -- Deprecated
local function ReturnAllowedRemoveAmount(itemName)
    if (Inventory[itemName] <= 0) then print("Remove Limit Reached for "..itemName) return 0 end
    return Inventory[itemName]
end
