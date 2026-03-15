ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Base Water Source" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = false  -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/pot/pot.mdl"
ENT.DefaultWaterAmount = 100
ENT.MaxWaterAmount = 100

function ENT:UpdateWaterAmount(name, old, new)
    self.WaterAmount = new
    self:CalculateBarProgress(new)
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "WaterAmount")
    
    if CLIENT then
        self:NetworkVarNotify("WaterAmount", self.UpdateWaterAmount)
    end
end

function ENT:SharedInitialize()
    local configSettings = VGFarmConfig.Water[self:GetClass()]
    if not configSettings then return end
    self.MaxWaterAmount = configSettings.MaxWaterAmount 

    if SERVER then
        self:SetWaterAmount(configSettings.DefaultWaterAmount)
    end
end
