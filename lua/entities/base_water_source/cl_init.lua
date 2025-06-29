include("shared.lua")

local fadeStart = 50
local maxDrawDistance = 300

local Clamp = math.Clamp
local Floor = math.floor
local DrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawMaterial = surface.SetMaterial
local DrawTexture = surface.DrawTexturedRect

local size = 32
local xOffset = -size/2
local yOffset = size/2
local frame = 0

local modelColor = Color(0, 0, 255, 255)

function ENT:DrawTranslucent()
    self:SetColor(modelColor)
    self:DrawModel()
end
