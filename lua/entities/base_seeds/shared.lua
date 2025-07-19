ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Seeds" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = false  -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.DefaultSeedAmount = 5 -- default amount
ENT.xGrid = 5
ENT.yGrid = 4
ENT.MaxGridAmount = ENT.xGrid * ENT.yGrid
ENT.MaxSeedAmount = ENT.MaxGridAmount * 2
ENT.FilledGrid = 0
ENT.PartialGrid = 0
ENT.EmptyGrid = 0
ENT.GrowTime = 10
ENT.CropClassName = "base_crop"
ENT.CropMinAmount = 1
ENT.CropMaxAmount = 2
ENT.Model = "models/seedPack2/seedPack2.mdl"
ENT.yGridOffset = 50
ENT.SeedIcon = Material("icons/seedPacks/questionMarkIcon.png")

local print = print
local Clamp = math.Clamp
local random = math.random

function ENT:UpdateGrid(name, old, new)
    print("Seed Amount Changed, Updating Grid | old: "..old.."  new: "..new)
    if new <= 0 then print("Skipped Grid Update") return end
    self:UpdateGridCache(new)
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "SeedAmount")

    if CLIENT then
        self:NetworkVarNotify("SeedAmount", self.UpdateGrid)
    end

end

function ENT:PrintTest()
    print(self.CropClassName.." Seeds with min and max "..self.CropMinAmount.." "..self.CropMaxAmount)
end

function ENT:GetRandomCropAmount(IsFertelized)
    if IsFertelized and self.CropMinAmount + 1 <= self.CropMaxAmount then return math.random(self.CropMinAmount + 1, self.CropMaxAmount) end
    return math.random(self.CropMinAmount, self.CropMaxAmount)
end

