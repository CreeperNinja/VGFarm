
-- 🅱️ Subtitle / Label Font
surface.CreateFont("InventoryLabel", {
   font = "Roboto",
   size = 18,
   weight = 500,
   antialias = true
})


eachMarketSize = 0
markets = { }

net.Receive("SendMarketData", function()
   local totalMarkets = net.ReadUInt(8)
   eachMarketSize = net.ReadUInt(8)
   local intBit = net.ReadUInt(6)
   print("Recieving Market Data")
   for i = 1, totalMarkets do
      marketName = net.ReadString()
      print("Market"..marketName)
      markets[marketName] = {}
      for g = 1, eachMarketSize do
         markets[marketName][g] = net.ReadUInt(intBit)  -- or WriteInt, WriteBool, etc. depending on your data
      end
   end
end)

net.Receive("SendNewMarketDataValues", function()
   local totalMarkets = net.ReadUInt(8)
   local intBit = net.ReadUInt(6)
   print("Started Receiving New Data")
   for i = 1, totalMarkets do
      local marketName = net.ReadString()
      table.remove(markets[marketName],1)
      local tableData = markets[marketName]
      tableData[eachMarketSize] = net.ReadUInt(intBit)
      print("Recieved new "..marketName.." values "..markets[marketName][eachMarketSize])
   end
end)


function ReturnNewUIElement(typeName, size, pos, title, isPopup, parent)
   element = vgui.Create(typeName, parent)

   element:SetSize(size[1] - 15, size[2] - 35)
   element:SetPos(pos[1] + 5, pos[2] + 30)
   element:SetTitle(title)

   if isPopup then element:MakePopup() end

   return element
end

function ReturnNewDockedUIElement(typeName, dockType, margins, size, title, isPopup, parent)
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

function CreateWindow()
   -- Create two frames side by side
   local mainUIFrame = vgui.Create("DFrame")

   local targetWidth, targetHeight = 1600, 800
   local screen_w, screen_h = ScrW(), ScrH()
   local x = screen_w / 2 - targetWidth / 2
   local y = screen_h / 2 - targetHeight / 2
   
   local animationTime, animationDelay, animationEase = 0.5, 0, 0.05
   local isAnimating = true 

   local rainbowSpeed = 20

   mainUIFrame:SetSize(targetWidth, 0)
   mainUIFrame:SetPos(x, y)
   mainUIFrame:SetTitle("Farming")
   mainUIFrame:MakePopup()

   local inventoryUIFrame = ReturnNewDockedUIElement("DFrame", LEFT, {0, 0, 0, 0}, {300, 0}, "Inventory", false , mainUIFrame)

   local inventoryLabels = {}
   // Create Label for each inventory item
   for key, value in pairs(playerInventory) do
      inventoryItemFrame = ReturnNewDockedUIElement("DPanel", TOP, {5, 2, 5, 2}, {50, 50},"", false , inventoryUIFrame)
      inventoryItemFrame.Paint = function(self, w, h)

         local borderWidth = 5
         // Border
         draw.RoundedBox(5, 0, 0, w, h, Color(82, 82, 82, 150))

         draw.RoundedBox(5, borderWidth, borderWidth, w - borderWidth*2, h - borderWidth*2, Color(82, 82, 82, 150))
      end
      
      inventoryLabels[key] = ReturnNewDockedUIElement("DLabel", LEFT, {5, 0, 0, 0}, {150, 25}, key.." = "..value or "None" , false , inventoryItemFrame)
      inventoryLabels[key]:SetFont("InventoryLabel")

      local sellButton = ReturnNewDockedUIElement("BarredButton", RIGHT, {5, 0, 10, 0}, {25, 25}, "Sell", false , inventoryItemFrame)
      sellButton.DoClick = function()
         SellAll(key)
         inventoryLabels[key]:SetText(key.." = "..playerInventory[key] or "None")
      end
   end

   local barSpeed = 2
   local barStatus = 0

   local sellAllButton = ReturnNewDockedUIElement("BarredButton", TOP, {5, 0, 0, 0}, {50, 25}, "Sell All", false , inventoryUIFrame)
   sellAllButton:SetBarColor(Color(180, 180, 180, 255))
   sellAllButton:SetBackgroundColor(Color(82, 82, 82, 150))
   sellAllButton.DoClick = function()
      SellAllCrops()
      for key, value in pairs(inventoryLabels) do
         value:SetText(key.." = "..playerInventory[key])
      end
   end

   local graphUIFrame = ReturnNewDockedUIElement("DFrame", FILL, {5, 0, 0, 0}, {300, 0}, "Market", false , mainUIFrame)

   local cropsButtonsHolder = ReturnNewDockedUIElement("DPanel", TOP, {0, 0, 0, 0}, {50, 25}, "", false , graphUIFrame)
   cropsButtonsHolder:SetPaintBackground(false)
   
   
   local graphButtons = {}
   local firstKey
   // Create Button for each crop
   for key, value in pairs(playerInventory) do
      if firstKey == nil then firstKey = key end
      graphButtons[key] = ReturnNewDockedUIElement("BarredButton", LEFT, {5, 0, 0, 0}, {100, 25}, key, false , cropsButtonsHolder)
   end

   // Sample market data
   local marketGraph = ReturnNewDockedUIElement("MGraph", FILL, {5, 0, 0, 0}, {0, 0}, firstKey, false , graphUIFrame)
   marketGraph:SetMarketData(markets[firstKey])

   // Assign function for each tab in the graph
   for key, value in pairs(graphButtons) do
      value.DoClick = function()
         marketGraph:SetCustomText(key)
         marketGraph:SetMarketData(markets[key])
      end
   end

   //Start Animating
   mainUIFrame:SizeTo(targetWidth, targetHeight, animationTime, animationDelay, animationEase, function() isAnimating = false end)

   //Centers The UI While animating
   mainUIFrame.OnSizeChanged = function(me)
      if isAnimating then me:Center() end
   end

end

hook.Add( "PlayerButtonDown", "OpenFarmingMenu", function( ply, button )
	if button != KEY_R then return end

	if CLIENT and not IsFirstTimePredicted() then return end

   CreateWindow()
end)
