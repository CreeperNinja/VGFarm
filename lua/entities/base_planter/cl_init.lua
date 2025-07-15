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
local waterColor = Color(0, 80, 255, alpha)

local function NoDraw(drawPos, drawAng) end

function ENT:UpdateDrawWaterDelegate()
    if self.frame >= 0 then
        self.DrawWater = function(drawPos, drawAng)
            render.SetMaterial(self.WaterLevelMaterial)
            self.WaterLevelMaterial:SetInt("$frame", self.frame)
            render.DrawQuadEasy(drawPos, drawAng, size, size, waterColor, 180)
        end
    else
        self.DrawWater = NoDraw -- no-op
        print("Removed Entity Water Level Rendering")
    end
end

function ENT:Initialize()
    self:UpdateDrawWaterDelegate()
    print("Default Frame: "..self.DefaultFrame)
    self.WaterLevelMaterial:SetInt("$frame", self.DefaultFrame)
end

function ENT:DrawTranslucent()
    self:DrawModel()

    local ply = LocalPlayer()
    local pos = ply:GetPos()
    local dist = pos:Distance(self:GetPos())
    -- if dist > maxDrawDistance then return end
    
    -- local alpha = 255
    -- if dist > fadeStart then
    --     local frac = Clamp((maxDrawDistance / dist) / (dist / fadeStart), 0, 1)
    --     alpha = alpha * frac
    -- end
    -- GRID DRAWING (on side of model)
    
    local drawPos = self:GetPos() + self:GetUp() * 75 
    local toEye = EyePos() - drawPos
    local normal = toEye:GetNormalized()
    local ang = self:GetAngles()

    self.DrawWater(drawPos, normal)

    cam.Start3D2D(self:GetPos() + self:GetForward() * 50 , ang, 1)
        VGFarmUtils.DrawBox(self.minHolderDetectionRange, self.maxHolderDetectionRange)
    cam.End3D2D()
end

