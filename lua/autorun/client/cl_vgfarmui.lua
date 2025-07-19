local VGFarm = include("sh_vgfarm.lua")

-- 🅱️ Subtitle / Label Font
surface.CreateFont("InventoryLabel", {
   font = "Roboto",
   size = 20,
   weight = 500,
   antialias = true
})

//Localized Functions
local ReadUInt = net.ReadUInt
local pairs = pairs
local DrawRoundedBox = draw.RoundedBox

//Localized params
local LEFT = LEFT
local RIGHT = RIGHT
local TOP = TOP
local BOTTOM = BOTTOM
local FILL = FILL

//Data
local markets = VGFarm.CropMarkets
local eachMarketSize = VGFarm.EachMarketSize
local totalMarkets = table.Count(markets)
local VGFarmPlayer = VGFarmPlayer

//Main Window Settings
local targetWidth, targetHeight = 1600, 800
local animationTime, animationDelay, animationEase = 0.5, 0, 0.05

local backgroundColor = Color(80, 80, 80, 255)

//Network Massages
net.Receive("SendMarketData", function()
   for i = 1, totalMarkets do
      marketName = VGFarm.SmartNetCropRead()
      markets[marketName] = {}
      for g = 1, eachMarketSize do
         markets[marketName][g] = VGFarmUtils.SmartNetFloatToIntRead()
      end
   end
end)

net.Receive("SendNewMarketDataValues", function()
   for i = 1, totalMarkets do
      local marketName = VGFarm.SmartNetCropRead()
      table.remove(markets[marketName],1)
      markets[marketName][eachMarketSize] = VGFarmUtils.SmartNetFloatToIntRead()
   end
end)

//functions

local function ReturnNewUIElement(typeName, size, pos, title, isPopup, parent)
   element = vgui.Create(typeName, parent)

   element:SetSize(size[1] - 15, size[2] - 35)
   element:SetPos(pos[1] + 5, pos[2] + 30)
   element:SetTitle(title)

   if isPopup then element:MakePopup() end

   return element
end

local function ReturnNewDockedUIElement(typeName, dockType, margins, size, title, isPopup, parent)
   element = vgui.Create(typeName, parent)

   if typeName == "DFrame" then 
      element:ShowCloseButton(false) 
      element:SetDraggable(false)
      element:SetTitle(title)

   elseif typeName == "DLabel" then
      element:SetText(title)

   elseif typeName == "DButton" then
      element:SetText(title)

   elseif typeName == "BarredButton" then
      element:SetCustomText(title)

   elseif typeName == "MGraph" then
      element:SetCustomText(title)
   end

   element:Dock(dockType)
   element:SetSize(size[1], size[2])
   element:DockMargin(margins[1], margins[2], margins[3], margins[4])

   if isPopup then element:MakePopup() end

   return element
end

local function CreateInventoryUI(parent, playerInv)

   local Labels = {}

   //Create Label for each inventory item
   for key, crop in pairs(VGFarm.Crops) do

      //Create Background
      inventoryItemFrame = ReturnNewDockedUIElement("DPanel", TOP, {0, 2, 0, 2}, {50, 50},"", false , parent)
      inventoryItemFrame.Paint = function(self, w, h)

         local borderWidth = 5
         // Border
         DrawRoundedBox(5, 0, 0, w, h, Color(82, 82, 82, 150))

         DrawRoundedBox(5, borderWidth, borderWidth, w - borderWidth*2, h - borderWidth*2, Color(82, 82, 82, 150))
      end
      
      //Create Text
      Labels[key] = ReturnNewDockedUIElement("DLabel", LEFT, {5, 0, 0, 0}, {150, 25}, crop.name.." = "..playerInv[crop.name] or "None" , false , inventoryItemFrame)
      Labels[key]:SetFont("InventoryLabel")

      //Create Sell Button
      local sellButton = ReturnNewDockedUIElement("BarredButton", RIGHT, {5, 5, 5, 5}, {50, 25}, "Sell", false , inventoryItemFrame)
      //sellButton:SetBackgroundColor(Color(165, 165, 165, 150))
      sellButton.DoClick = function()
         VGFarmPlayer:SendSellCropRequest(crop.name)
         Labels[key]:SetText(VGFarm.Crops[key].name .." = "..0 or "None")
      end
   end

   return Labels

end

//Main UI
local function CreateWindow()

   //Window Generated Settings
   local screen_w, screen_h = ScrW(), ScrH()
   local x = screen_w / 2 - targetWidth / 2
   local y = screen_h / 2 - targetHeight / 2
   local isAnimating = true 

   //Data
   local playerInv = VGFarmPlayer:GetPlayerFarmInventory()

   //Creates A main Window Frame
   local mainUIFrame = vgui.Create("DFrame")

   mainUIFrame:SetSize(targetWidth, 0)
   mainUIFrame:SetPos(x, y)
   mainUIFrame:SetTitle("Farming")
   mainUIFrame:MakePopup()

   //Inventory
   local inventoryUIFrame = ReturnNewDockedUIElement("DFrame", LEFT, {0, 0, 0, 0}, {300, 0}, "Inventory", false , mainUIFrame)

   local inventoryLabels = CreateInventoryUI(inventoryUIFrame, playerInv)

   local sellAllButton = ReturnNewDockedUIElement("BarredButton", TOP, {0, 0, 0, 0}, {50, 25}, "Sell All", false , inventoryUIFrame)
   sellAllButton:SetBarColor(Color(180, 180, 180, 255))
   sellAllButton:SetBackgroundColor(Color(82, 82, 82, 255))
   sellAllButton.DoClick = function()
      VGFarmPlayer:SendSellAllCropsRequest()
      for key, value in pairs(inventoryLabels) do
         value:SetText(VGFarm.Crops[key].name .." = ".. 0)
      end
   end

   //Graph
   local graphUIFrame = ReturnNewDockedUIElement("DFrame", FILL, {5, 0, 0, 0}, {300, 0}, "Market", false , mainUIFrame)

   local cropsButtonsHolder = ReturnNewDockedUIElement("DPanel", TOP, {0, 0, 0, 0}, {50, 25}, "", false , graphUIFrame)
   cropsButtonsHolder:SetPaintBackground(false)
   
   local firstCrop = nil 
   local graphButtons = {}

   //Create Button for each crop type
   for key, crop in pairs(VGFarm.Crops) do
      if firstCrop == nil then firstCrop = crop.name end
      graphButtons[key] = ReturnNewDockedUIElement("BarredButton", LEFT, {0, 0, 0, 0}, {100, 25}, crop.name, false , cropsButtonsHolder)
      graphButtons[key]:SetBackgroundColor(Color(85, 85, 85))
   end

   //Creates The graph Part
   local marketGraph = ReturnNewDockedUIElement("MGraph", FILL, {0, 0, 0, 0}, {0, 0}, firstCrop, false , graphUIFrame)
   marketGraph:SetMaxMarketValue(VGFarm.Crops[VGFarm.CropsIDs[firstCrop]].baseMarketPrice * VGFarm.MaxCropPriceMultiplier)
   marketGraph:SetMarketData(markets[firstCrop])

   //Assign function for each tab
   for key, value in pairs(graphButtons) do
      local cropName = VGFarm.Crops[key].name
      value.DoClick = function()
         marketGraph:SetCustomText(cropName)
         marketGraph:SetMaxMarketValue(VGFarm.Crops[VGFarm.CropsIDs[cropName]].baseMarketPrice * VGFarm.MaxCropPriceMultiplier)
         marketGraph:SetMarketData(markets[cropName])
      end
   end

   //Start Animating
   mainUIFrame:SizeTo(targetWidth, targetHeight, animationTime, animationDelay, animationEase, function() isAnimating = false end)

   //Centers The UI While animating
   mainUIFrame.OnSizeChanged = function(me)
      if isAnimating then me:Center() end
   end

end

concommand.Add("vgfarm_open_sell_menu", function(ply, cmd, args)
   CreateWindow()
end)
