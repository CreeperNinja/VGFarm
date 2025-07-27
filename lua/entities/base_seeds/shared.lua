ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Seeds" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = false  -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--Model
ENT.Model = "models/seedpack/seedpack.mdl"

--Grid
ENT.xGrid = 5
ENT.yGrid = 4
ENT.MaxGridAmount = ENT.xGrid * ENT.yGrid
ENT.MaxSeedAmount = ENT.MaxGridAmount * 2
ENT.yGridOffset = 50

--Seed
ENT.DefaultSeedAmount = 5 -- default amount
ENT.GrowTime = 10
ENT.CropMinAmount = 1
ENT.CropMaxAmount = 2
ENT.SeedIcon = Material("icons/seedPacks/questionMarkIcon.png")

--Crop - the crop nane that this seed will produce
ENT.CropClassName = "base_crop"

local print = print
local Clamp = math.Clamp
local random = math.random

function ENT:UpdateGrid(name, old, new)
    if new <= 0 then return end
    self:CalculateGridBoxes(new)
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "SeedAmount")

    if CLIENT then
        self:NetworkVarNotify("SeedAmount", self.UpdateGrid)
    end

end

function ENT:GetRandomCropAmount(IsFertelized)
    if IsFertelized and self.CropMinAmount + 1 <= self.CropMaxAmount then return math.random(self.CropMinAmount + 1, self.CropMaxAmount) end
    return math.random(self.CropMinAmount, self.CropMaxAmount)
end

