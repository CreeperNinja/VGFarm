-- Define a new panel derived from DButton
local PANEL = {}

-- Called when the button is initialized
function PANEL:Init()
    self:SetText("Text")
    self:SetSize(100, 40)
end

-- Called every frame to paint the button
function PANEL:Paint(w, h)
    -- Draw a background color
    surface.SetDrawColor(0, 0, 0) -- Blue color
    surface.DrawRect(0, 0, w, h)

    -- Draw the button text
    draw.SimpleText("Text", "DermaDefault", w * 0.5, h * 0.25, color_white, TEXT_ALIGN_CENTER)
end

-- Register your new panel as "MyCustomButton"
vgui.Register("BarredButton", PANEL, "DButton")
