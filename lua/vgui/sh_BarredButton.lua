local PANEL = {}

//Localized Functions
local Clamp = math.Clamp
local SetDrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawSimpleText = draw.SimpleText

-- 🔘 Button Text Font
surface.CreateFont("BButtonText", {
    font = "Roboto",
    size = 20,
    weight = 400,
    antialias = true
})

function PANEL:Init()
    self:SetSize(100, 40)
    self:SetText("")
    self.backgroundColor = {82, 82, 82, 82}
    self.barSpeed = 5
    self.barColor = Color(160, 160, 160, 255)
    self.barStatus = 0
    self.customText = ""
    self.customTextColor = Color(255, 255, 255, 255)
end

function PANEL:Paint(w, h)  

    // Change Status Bar Size Based On Hover State
    if self:IsHovered() then
        self.barStatus = Clamp(self.barStatus + self.barSpeed * FrameTime(), 0, 1)
    else 
        self.barStatus = Clamp(self.barStatus - self.barSpeed * FrameTime(), 0, 1)
    end

    // Draw background 
    SetDrawColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    DrawRect(0, 0, w, h)

    // Draw bar
    SetDrawColor(self.barColor)
    DrawRect(0, h * 0.9, w * self.barStatus, h * 0.1)
    
    // Draw text
    DrawSimpleText(self.customText, "BButtonText", w * 0.5, h * 0.5, self.customTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

// When the panel is ready for layout, set the background color to blue
function PANEL:PerformLayout()
	self:SetBGColor(self:GetBGColor())
end

function PANEL:SetCustomText(text)
    self.customText = text
end

function PANEL:SetBarColor(color)
    self.barColor = color
end

function PANEL:SetCustomTextColor(color)
    self.customTextColor = color
end

function PANEL:SetBackgroundColor(r, g, b, a)
    self.backgroundColor = {r, g, b, a}
end

vgui.Register("BarredButton", PANEL, "DButton")
