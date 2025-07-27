include("shared.lua")

surface.CreateFont("SeedFont", {
    font = "Roboto",
    size = 48,
    weight = 700,
    antialias = true,
})

--alpha controll for viewing draws
local fadeStart = 100
local maxDrawDistance = 300

--crop icon
local iconSize = 64
local iconOffsetX = -iconSize/4
local iconOffsetY = -iconSize/4*3

--Localized Functions
local Clamp = math.Clamp
local Floor = math.floor
local DrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawMaterial = surface.SetMaterial
local DrawTexture = surface.DrawTexturedRect

--Grid Settings
local spacing = 2
local size = 10
local gridStartPoint = size + spacing
local seedGrid = {}

--Generates all x and y points in the grid
function ENT:GenerateSeedPackGrid()
    local gridIndex = self.xGrid * 1000 + self.yGrid
    if seedGrid[gridIndex] then return end
    
    seedGrid[gridIndex] = {x = {}, y = {}}
    local xPoints = seedGrid[gridIndex].x
    local yPoints = seedGrid[gridIndex].y
    
    local rows = self.xGrid
    local cols = self.yGrid
    local startX = -((rows-1) * gridStartPoint / 2 - size/2 - spacing*1.5)
    local startY = -((cols+1) * gridStartPoint / 2 - size/2 - spacing*1.5) + self.yGridOffset

    for i = 0, self.MaxGridAmount do
        local xPoint = gridStartPoint * (i % rows) + startX
        local yPoint = gridStartPoint * (Floor((i)  / rows) % cols) + startY
        xPoints[i + 1] = xPoint
        yPoints[i + 1] = yPoint
    end
    VGFarmUtils.SmartPrint("Created "..rows.."x "..cols.."y Seeed Grid "..#xPoints.." Total Points")
end

--Calculates how many grid boxes each color will take
function ENT:CalculateGridBoxes(seedCount)
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

function ENT:DrawSeedGrid(pos, ang, alpha)
    local gridIndex = self.xGrid * 1000 + self.yGrid
    local gridPoints = seedGrid[gridIndex]

    local xPoints = gridPoints.x
    local yPoints = gridPoints.y

    local filled = self.FilledGrid
    local partial = self.PartialGrid

    DrawColor(0, 255, 0, alpha)
    for i = 1, filled do
        DrawRect(xPoints[i], yPoints[i], size, size)
    end

    DrawColor(255, 255, 0, alpha)
    local index = filled + 1
    for i = index, partial do
        DrawRect(xPoints[i], yPoints[i], size, size)
    end

    DrawColor(100, 100, 100, alpha)
    index = partial + 1
    for i = index, index + self.EmptyGrid - 1 do
        DrawRect(xPoints[i], yPoints[i], size, size)
    end
end

function ENT:Initialize()
    self:GenerateSeedPackGrid()
    self:CalculateGridBoxes(self:GetSeedAmount())
end

function ENT:DrawTranslucent()
    self:DrawModel()

    local ply = LocalPlayer()
    local pos = ply:GetPos()
    local dist = pos:Distance(self:GetPos())
    
    if dist > maxDrawDistance then return end
    
    local alpha = 255
    if dist > fadeStart then
        local frac = Clamp((maxDrawDistance / dist) / (dist / fadeStart), 0, 1)
        alpha = alpha * frac
    end
    local gridPos = self:GetPos() + self:GetRight() + self:GetUp() * 1.5
    local gridAng = self:GetAngles()

    gridAng:RotateAroundAxis(gridAng:Up(), 90)

    cam.Start3D2D(gridPos, gridAng, 0.1)
        DrawColor(255, 255, 255, alpha)
        DrawMaterial(self.SeedIcon)
        DrawTexture(iconOffsetX, iconOffsetY, iconSize, iconSize) -- Draw centered
        self:DrawSeedGrid(gridPos, gridAng, alpha)
    cam.End3D2D()
end

