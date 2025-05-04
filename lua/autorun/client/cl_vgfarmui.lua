
crops = {"Carrots", "Potatos", "Cucumbers"}

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
   end

   element:Dock(dockType)
   element:SetSize(size[1], size[2])
   element:DockMargin(margins[1], margins[2], margins[3], margins[4])

   if isPopup then element:MakePopup() end

   return element
end

function CreateInventoryLabels(parent)
   buttonA = ReturnNewDockedUIElement("DLabel", TOP, {5, 0, 0, 0}, {50, 25}, "Carrots = 0", false , parent)
   buttonB = ReturnNewDockedUIElement("DLabel", TOP, {5, 0, 0, 0}, {50, 25}, "Potatos = 0", false , parent)
   buttonC = ReturnNewDockedUIElement("DLabel", TOP, {5, 0, 0, 0}, {50, 25}, "Cucumbers = 0", false , parent)
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
   CreateInventoryLabels(inventoryUIFrame)

   local barSpeed = 2
   local barStatus = 0
   local sellAllButton = ReturnNewDockedUIElement("DButton", TOP, {5, 0, 0, 0}, {50, 25}, "", false , inventoryUIFrame)
   sellAllButton.Paint = function(me, w, h)
      if me:IsHovered() then
         barStatus = math.Clamp(barStatus + barSpeed * FrameTime(), 0, 1)
      else 
         barStatus = math.Clamp(barStatus - barSpeed * FrameTime(), 0, 1)
      end

      rainbowColor =  HSVToColor(CurTime() * rainbowSpeed % 360, 1, 1)
      surface.SetDrawColor(me:GetColor())
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor(rainbowColor)
      surface.DrawRect(0, h * 0.9, w * barStatus, h * 0.1)
      draw.SimpleText("Sell All", "DermaDefault", w * 0.5, h * 0.25, color_white, TEXT_ALIGN_CENTER)
   end

   local testCustomButton = ReturnNewDockedUIElement("BarredButton", TOP, {5, 0, 0, 0}, {50, 25}, "", false , inventoryUIFrame)

   local graphUIFrame = ReturnNewDockedUIElement("DFrame", FILL, {5, 0, 0, 0}, {300, 0}, "Market", false , mainUIFrame)
   local testMenu = ReturnNewDockedUIElement("DMenuBar", TOP, {5, 0, 0, 0}, {50, 25}, "Bar", false , graphUIFrame)
   testMenu:AddMenu(crops[1])
   testMenu:AddMenu(crops[2])
   testMenu:AddMenu(crops[3])

   local marketGraph = ReturnNewDockedUIElement("DPanel", FILL, {5, 0, 0, 0}, {300, 0}, "Market", false , graphUIFrame)
   marketGraph:SetPaintBackground(false)

   //Start Animating
   mainUIFrame:SizeTo(targetWidth, targetHeight, animationTime, animationDelay, animationEase, function() isAnimating = false end)

   //Centers The UI While animating
   mainUIFrame.OnSizeChanged = function(me)
      if isAnimating then me:Center() end
   end

end

hook.Add( "PlayerButtonDown", "OpenFarmingMenu", function( ply, button )
	if button != KEY_V then return end

	if CLIENT and not IsFirstTimePredicted() then return end

   CreateWindow()
end)
