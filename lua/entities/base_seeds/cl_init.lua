include("shared.lua")

surface.CreateFont("SeedFont", {
    font = "Roboto",
    size = 48,
    weight = 700,
    antialias = true,
})

local fadeStart = 50
local maxDrawDistance = 300

local iconSize = 64
local iconOffsetX = -iconSize/4
local iconOffsetY = -iconSize/4*3

local Clamp = math.Clamp
local Floor = math.floor
local DrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawMaterial = surface.SetMaterial
local DrawTexture = surface.DrawTexturedRect

function ENT:UpdateGridCache(seedCount)
    local gridAmount = self.MaxGridAmount
    //Calculate amount Exceeding the grid
    local filled = Clamp(seedCount - gridAmount, 0, gridAmount)
    self.FilledGrid = filled

    //Calculate amount Filling the grid
    local partial = Clamp(seedCount - filled, 0, gridAmount)
    self.PartialGrid = partial

    //Calculate amount Missing the grid
    local empty = Clamp(gridAmount - partial - filled, 0, gridAmount)
    self.EmptyGrid = empty
end

function ENT:Initialize()
    self:UpdateGridCache(self.DefaultSeedAmount)
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
    
    local gridPos = self:GetPos() + self:GetRight() + self:GetUp() * 2.1
    local gridAng = self:GetAngles()

    gridAng:RotateAroundAxis(gridAng:Up(), 90)

    cam.Start3D2D(gridPos, gridAng, 0.1)
        DrawColor(255, 255, 255, 255)
        DrawMaterial(self.SeedIcon)
        DrawTexture(iconOffsetX, iconOffsetY, iconSize, iconSize) -- Draw centered
        self:DrawSeedGrid(gridPos, gridAng, alpha)
    cam.End3D2D()
end

//Grid Settings
local spacing = 2
local size = 10
local gridStartPoint = size + spacing

function ENT:DrawSeedGrid(pos, ang, alpha)
    local seedCount = self:GetSeedAmount()
    local filled = self.FilledGrid
    local partial = self.PartialGrid
    local empty = self.EmptyGrid

    //print("Green: "..filled.."    Yellow: "..partial.."    Gray: "..empty)

    local rows = self.xGrid
    local cols = self.yGrid
    local startX = -((rows-1) * gridStartPoint / 2 - size/2 - spacing*1.5)
    local startY = -((cols+1) * gridStartPoint / 2 - size/2 - spacing*1.5) + self.yGridOffset

    local gridIndex = 0
    DrawColor(0, 255, 0, alpha)
    for i = 0, filled - 1 do
        DrawRect(gridStartPoint * (i % rows) + startX, gridStartPoint * (Floor((i)  / rows) % cols) + startY, size, size)
    end

    DrawColor(255, 255, 0, alpha)
    gridIndex = filled
    for i = gridIndex, partial - 1 do
        DrawRect(gridStartPoint * (i % rows) + startX, gridStartPoint * (Floor((i)  / rows) % cols) + startY, size, size)
    end

    DrawColor(100, 100, 100, alpha)
    gridIndex = partial
    for i = gridIndex, gridIndex + empty - 1 do
        DrawRect(gridStartPoint * (i % rows) + startX, gridStartPoint * (Floor((i)  / rows) % cols) + startY, size, size)
    end
end
