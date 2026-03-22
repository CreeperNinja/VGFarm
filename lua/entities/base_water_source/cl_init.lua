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

local modelColor = Color(255, 255, 255)

local drawSize = Vector(50, 10)
local widthQuarterPoint = drawSize.x / 4
local drawPoint = drawSize / 2
local WaterAmountDrawOffsetZ = 30

local WaterLevelBone = nil 

function ENT:Initialize()
    self:SharedInitialize()
    self:CalculateBarProgress(self:GetWaterAmount())

    WaterLevelBone = self:LookupBone("WaterLevelB")
end

function ENT:CalculateBarProgress(amount)
    self.WaterAmountBarProgress = amount / self.MaxWaterAmount
    if WaterLevelBone then
        self:ManipulateBoneScale(WaterLevelBone, Vector(1,self.WaterAmountBarProgress,1))
    end
end

function ENT:DrawTranslucent()
    self:SetColor(modelColor)
    self:DrawModel()

    local drawPos = self:GetPos() + self:GetUp() * WaterAmountDrawOffsetZ - self:GetRight() * widthQuarterPoint
    local ang = self:GetAngles()

    ang:RotateAroundAxis(self:GetRight(), 90)
    ang:RotateAroundAxis(self:GetForward(), -90)

    -- cam.Start3D2D(drawPos, ang, 1)
    --     surface.SetDrawColor(modelColor)
    --     surface.DrawRect(-drawPoint.x, -drawPoint.y, drawPoint.x * self.WaterAmountBarProgress, drawPoint.y)
    -- cam.End3D2D()
end
