include("shared.lua")


local fadeStart = 50
local maxDrawDistance = 300

local Clamp = math.Clamp
local Floor = math.floor
local DrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawMaterial = surface.SetMaterial
local DrawTexture = surface.DrawTexturedRect

local size = 16
local xOffset = -size/2
local yOffset = size/2
local color = Color(255, 255, 255, alpha)

function ENT:Initialize()
    self.WaterLevelMaterial = CreateMaterial("water_frame_" .. self:EntIndex(), "UnlitGeneric", {
    ["$basetexture"] = self.WaterLevelMaterialPath,
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
    ["$frame"] = "0",
    ["$nocull"] = "1",
    ["$clamps"] = "1",
    ["$clampt"] = "1"
})

    self.WaterLevelMaterial:SetInt("$frame", self.DefaultFrame)
end

function ENT:DrawTranslucent()
    self:DrawModel()

    local ply = LocalPlayer()
    local pos = ply:GetPos()
    local dist = pos:Distance(self:GetPos())
    if dist > maxDrawDistance then return end
    
    // 
    local alpha = 255
    if dist > fadeStart then
        local frac = Clamp((maxDrawDistance / dist) / (dist / fadeStart), 0, 1)
        alpha = alpha * frac
    end
    -- GRID DRAWING (on side of model)
    
    local drawPos = self:GetPos() + self:GetUp() * 75 
    local toEye = EyePos() - drawPos
    local normal = toEye:GetNormalized()
    render.SetMaterial(self.WaterLevelMaterial)
    render.DrawQuadEasy(drawPos, normal, size, size, color, 180)

end

