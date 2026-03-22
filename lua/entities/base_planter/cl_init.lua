include("shared.lua")
local RadialProgressBar = include("modules/RadialProgressBar.lua")

surface.CreateFont("WaterText", {
    font = "Tahoma",
    size = 64,
    weight = 50,
    antialias = true
})

--Localized functions
local Clamp = math.Clamp
local Floor = math.floor
local DrawColor = surface.SetDrawColor
local DrawRect = surface.DrawRect
local DrawMaterial = surface.SetMaterial
local DrawTexture = surface.DrawTexturedRect

--Plant Visuals
local plantModelPath = "models/plant/plant.mdl"
local plantTotalStages = 5

--Water Level Drawing vars
local waterBarRadius = 150
local waterImageDrawYOffset = Vector(0, 0, waterBarRadius/2)

--list of models with each one having it's own list of vectors
local modelInfoDrawPoints = {}
local modelPlantDrawPoints = {}
local modelPlantLineDrawPoints = {}

local modelInfoScale = 0.07 --Used To scale the text and point placment on the x axis of the model
local seedInfoDrawYOffset = Vector(0, 0, 50)

local textAllign = TEXT_ALIGN_CENTER

local function NoWaterDraw() end
local function NoPlantDraw() end

function ENT:UpdateDrawWaterDelegate(progressFloat)
    if progressFloat <= 0 then 
        self.DrawWater = NoWaterDraw --makes the draw operation do nothing 
        VGFarmUtils.SmartPrint("Removed Entity Water Level Rendering") 
        return 
    end
    
    --if water bar doesn't exist, create it
    if not self.waterBar then self.waterBar = RadialProgressBar:New(waterBarRadius, progressFloat, self.waterColor) end

    self.waterBar:BuildUVs(waterBarRadius, progressFloat)

    self.DrawWater = function(drawPos, drawAng)
        local percent = string.format("%.1f%%", progressFloat * 100)
        cam.Start3D2D(drawPos , drawAng, modelInfoScale)
            self.waterBar:ExternalDraw()
            draw.SimpleTextOutlined(percent, "DirtTextFont", 0, 0, self.textColor, textAllign, textAllign, 3, self.outlineColor)
        cam.End3D2D()
    end
end

local function ResetSeedProgress()
    VGFarmUtils.SmartPrint("Recieved Reset Growth Visuals")
    local planter = net.ReadEntity()

    for plantIndex = 1, planter.SeedLimit do
        planter.Seeds[plantIndex] = 0
        planter.cachedPlantModelStages[plantIndex].drawToggle = false  
    end
end

net.Receive("SendResetSeedProgressToClient", ResetSeedProgress)

local function RecieveSeedGrowthProgressToClient()
    VGFarmUtils.SmartPrint("Recieved Growth Info For Plants")
    local entitiesCount = VGFarmUtils.SmartNetUIntRead()

    for i = 1, entitiesCount do
        local planter = net.ReadEntity()
        local totalSeeds = VGFarmUtils.SmartNetUIntRead()

        for x = 1, totalSeeds do
            local seedKey = VGFarmUtils.SmartNetUIntRead()
            local seedProgressPercent = VGFarmUtils.SmartNetUIntRead()
            if seedProgressPercent >= 100 then 
                VGFarmUtils.SmartPrint("Finished Growing Detected") 
                planter.Seeds[seedKey] = 0
                planter.cachedPlantModelStages[seedKey].drawToggle = false  
                continue 
            end
            planter.Seeds[seedKey] = seedProgressPercent
            VGFarmUtils.SmartPrint("Recieved Growth "..seedProgressPercent.."% for spot "..seedKey)
            planter:SetPlantStage(seedKey, seedProgressPercent)
        end
    end
end

net.Receive("SendSeedGrowthProgressToClient", RecieveSeedGrowthProgressToClient)


function ENT:GeneratePlantPoints(model)
    local mins, maxs = self:GetModelBounds()

    --internal padding values
    local widthPadding = 0
    local lengthPadding = 3

    --Internal Offset values
    local plantHeightOffset = 3

    local width  = maxs.y - mins.y - widthPadding
    local length = maxs.x - mins.x - lengthPadding
    local height = maxs.z - mins.z
    VGFarmUtils.SmartPrint("Model Height: "..height)

    local perRow = math.min(self.SeedLimit, self.SeedInfoPerRow)
    local totalRows = math.ceil(self.SeedLimit / self.SeedInfoPerRow)

    local spacingY = width / perRow
    local spacingX = length / totalRows

    local halfCols = (perRow - 1) / 2
    local halfRows = (totalRows - 1) / 2
    local halfHeight = height / 2

    modelPlantDrawPoints[model] = {}

    for i = 1, self.SeedLimit do
        local col = (i - 1) % perRow
        local row = math.floor((i - 1) / perRow)

        local posX = (row - halfRows) * spacingX
        local posY = (col - halfCols) * spacingY
        local posZ = halfHeight - plantHeightOffset

        modelPlantDrawPoints[model][i] = Vector(posX, posY, posZ)
    end
end

--Generates points on the model based on its width and length, with the length being offset a little
function ENT:GeneratePoints(model)
    local modelMins, modelMaxs = self:GetModelBounds()

    --width
    local modelWidth = modelMaxs.y - modelMins.y 
    local modelWidth2D = modelWidth / modelInfoScale
    local modelHalfWidth2D = modelWidth2D / 2
    local spacingWidth = modelWidth2D / math.min(self.SeedLimit, self.SeedInfoPerRow)

    --length
    local modelLength = modelMaxs.z - modelMins.z 
    local modelLength2D = modelLength * 1.5 * (math.ceil(self.SeedLimit % 2) - 1.25) --change this line to make it perfectly devided or devided with an offset
    local modelHalfLength2D = modelLength2D / 2
    local spacingLength = modelLength2D / math.ceil(self.SeedLimit / self.SeedInfoPerRow)

    modelInfoDrawPoints[model] = {}
    modelPlantLineDrawPoints[model] = {}
    
    for i = 1, self.SeedLimit do
        local rowIndex = math.ceil((i - 0.5) / self.SeedInfoPerRow)
        local columbIndex = (i - 0.5) % self.SeedInfoPerRow

        local xOffset = -modelHalfWidth2D + columbIndex * spacingWidth
        local yOffset = math.floor((i - 1) / self.SeedInfoPerRow) --might want to review this line of code as I don't remember it's significants 
        local zOffset = modelHalfLength2D - (rowIndex - 0.5) * spacingLength

        local plantX = modelHalfLength2D - (rowIndex - 0.5) * modelInfoScale
        local plantZ = modelLength / 2 + (rowIndex - 0.5) * spacingLength

        modelInfoDrawPoints[model][i] = Vector(xOffset, yOffset, zOffset)
        modelPlantLineDrawPoints[model][i] = {bottom = Vector(xOffset, 600, zOffset), top = Vector(xOffset, 0, zOffset)}
    end
    
    VGFarmUtils.SmartPrint("Model Width Created for "..self:GetClass())
end

--Currently Not in Use But will be used to extract specific bone locations to create points
function ENT:ExtractPointsFromModelBones(model) return false end

function ENT:SetPoints()
    local model = self:GetModel()

    if modelInfoDrawPoints[model] then return end

    if self:ExtractPointsFromModelBones(model) then return end

    self:GeneratePoints(model)
    self:GeneratePlantPoints(model)
end

function ENT:BuildPlantModels(modelPath)
    self.plantModels = {} -- store separate model instances
    self.cachedPlantModelStages = {} -- stores last cached model stage

    for i = 1, self.SeedLimit do
        local plant = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
        plant:SetNoDraw(true) -- you will draw manually in Draw()
        self.plantModels[i] = plant
        self.cachedPlantModelStages[i] = {stage = plantTotalStages, drawToggle = false}
    end
end

function ENT:SetColors()
    self.waterColor = Color(VGFarmClientConfig.WaterBarColor.r, VGFarmClientConfig.WaterBarColor.g, VGFarmClientConfig.WaterBarColor.b, 255)
    self.textColor = Color(VGFarmClientConfig.TextColor.r, VGFarmClientConfig.TextColor.g, VGFarmClientConfig.TextColor.b, 255)
    self.outlineColor = Color(VGFarmClientConfig.TextOutlineColor.r, VGFarmClientConfig.TextOutlineColor.g, VGFarmClientConfig.TextOutlineColor.b, 255)
end

function ENT:Initialize()
    self:SharedInitialize()
    self:UpdateDrawWaterDelegate(self.DefaultWaterAmount / self.MaxWaterAmount)
    self:SetPoints()
    self:SetColors()

    self:BuildPlantModels(plantModelPath)
    for i = 1, self.SeedLimit do
        self.Seeds[i] = 0
    end
    --self.debbugBoxEnabled = false --holder code, might make it a toggle feature when a player wants to see an area
end


local function DrawSeedText(pos, ang, scale, drawPoints, seeds, seedLimit, textColor, outlineColor, toggleDrawLines, linePoints, plantModel)
    cam.Start3D2D(pos, ang, scale)
        for i = 1, seedLimit do
            local point = drawPoints[i]
            draw.SimpleTextOutlined(
                seeds[i].."%", "WaterText",
                point.x, point.y * 100,
                textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
                3, outlineColor
            )
            if toggleDrawLines then 
                render.DrawLine(linePoints[i].bottom, linePoints[i].top, textColor, true) 
            end
        end
    cam.End3D2D()
end

function ENT:DrawGrowthInfo(drawPos, ang)
    local drawPoints = modelInfoDrawPoints[self.Model]
    local plantPoints = modelPlantLineDrawPoints[self.Model]

    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)
    DrawSeedText(drawPos, ang, modelInfoScale, drawPoints, self.Seeds, self.SeedLimit, self.textColor, self.outlineColor, false)

    ang:RotateAroundAxis(ang:Right(), 180)
    DrawSeedText(drawPos, ang, modelInfoScale, drawPoints, self.Seeds, self.SeedLimit, self.textColor, self.outlineColor, true, plantPoints, self.plantModel)
end

function ENT:SetPlantStage(plantIndex, seedProgressPercent)
    local stage = math.floor(seedProgressPercent / (100 / plantTotalStages))
    
    --Early Exit if Plant Stage Is Repeated
    if self.cachedPlantModelStages[plantIndex].stage == stage then return end

    self.plantModels[plantIndex]:SetBodygroup(0, stage)
    self.cachedPlantModelStages[plantIndex].stage = stage

    if not self.cachedPlantModelStages[plantIndex].drawToggle then 
        VGFarmUtils.SmartPrint("Toggled plant draw on in spot "..plantIndex.." (Toggled)")
        self.cachedPlantModelStages[plantIndex].drawToggle = true 
    end
end

function ENT:PlantDraw(model)
    local points = modelPlantDrawPoints[model]
    if not self.plantModels then return end

    for plantIndex = 1, self.SeedLimit do
        --Optional optimization: have a list of only turned on plants
        if not self.cachedPlantModelStages[plantIndex].drawToggle then continue end

        local plant = self.plantModels[plantIndex]
        local localPos = points[plantIndex]

        if plant and localPos then
            -- Transform the local offset & rotation into world space
            plant:SetPos(self:LocalToWorld(localPos))
            plant:SetAngles(self:LocalToWorldAngles(Angle(0, 0, 0))) -- replace with offset if needed
            
            plant:DrawModel()
        end
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()
    
    local playerPos = LocalPlayer():GetPos()
    local dirtPos = self:GetPos()
    local distSqr = playerPos:DistToSqr(dirtPos)
    local model = self:GetModel()
    
    --Early Exit to not render info if too far away
    if distSqr > VGFarmClientConfig.maxDrawDistanceSqr or not modelInfoDrawPoints[model] then return end

    --Creates a constant horizontal view
    local yaw = (playerPos - dirtPos):Angle().y
    local drawAng = Angle(0, yaw + 90, 90)
    local modelAng = self:GetAngles()

    --Fade effect when getting further
    local alpha = 255
    if distSqr > VGFarmClientConfig.fadeStart then
        local frac = Clamp((VGFarmClientConfig.maxDrawDistanceSqr / distSqr) / (distSqr / VGFarmClientConfig.fadeStartSqr), 0, 1)
        alpha = alpha * frac
    end

    self.waterColor.a = alpha
    self.textColor.a = alpha
    self.outlineColor.a = alpha
    
    self:PlantDraw(model)
    
    self:DrawGrowthInfo(dirtPos + self:GetUp() * 52 , modelAng)
    
    self.DrawWater(dirtPos + waterImageDrawYOffset, drawAng)
end

function ENT:OnRemove()
    if IsValid(self.plantModels) then
        self.plantModels:Remove()
    end
end

