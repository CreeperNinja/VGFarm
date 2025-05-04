
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

   local targetWidth, targetHeight = 1200, 800
   local screen_w, screen_h = ScrW(), ScrH()
   local x = screen_w / 2 - targetWidth / 2
   local y = screen_h / 2 - targetHeight / 2
   
   local animationTime, animationDelay, animationEase = 0.5, 0, 0.05
   local isAnimating = true 

   local rainbowSpeed = 20

   mainUIFrame:SetSize(0, 0)
   mainUIFrame:SetPos(x, y)
   mainUIFrame:SetTitle("Farming")
   mainUIFrame:MakePopup()

   local inventoryUIFrame = ReturnNewDockedUIElement("DFrame", LEFT, {0, 0, 0, 0}, {300, 0}, "Inventory", false , mainUIFrame)

   local inventoryLabels = {}
   // Create Label for each inventory item
   for key, value in pairs(playerInventory) do
      inventoryLabels[key] = ReturnNewDockedUIElement("DLabel", TOP, {5, 0, 0, 0}, {50, 25}, key.." = "..value or "None" , false , inventoryUIFrame)
   end

   local barSpeed = 2
   local barStatus = 0

   local sellAllButton = ReturnNewDockedUIElement("BarredButton", TOP, {5, 0, 0, 0}, {50, 25}, "Sell All", false , inventoryUIFrame)
   sellAllButton:SetBarColor(Color(180, 180, 180, 255))
   sellAllButton.DoClick = function()
      SellAll()
      for key, value in pairs(inventoryLabels) do
         value:SetText(key.." = "..playerInventory[key])
      end
   end

   local graphUIFrame = ReturnNewDockedUIElement("DFrame", FILL, {5, 0, 0, 0}, {300, 0}, "Market", false , mainUIFrame)

   local cropsButtonsHolder = ReturnNewDockedUIElement("DPanel", TOP, {0, 0, 0, 0}, {50, 25}, "", false , graphUIFrame)
   cropsButtonsHolder:SetPaintBackground(false)
   
   // Create Button for each crop
   for key, value in pairs(playerInventory) do
      ReturnNewDockedUIElement("BarredButton", LEFT, {5, 0, 0, 0}, {75, 25}, key, false , cropsButtonsHolder)
   end

   local marketGraph = ReturnNewDockedUIElement("DPanel", BOTTOM, {5, 0, 0, 0}, {300, 0}, "Market", false , graphUIFrame)
   marketGraph:SetPaintBackground(false)

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
