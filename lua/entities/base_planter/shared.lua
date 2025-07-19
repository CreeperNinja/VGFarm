ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Base Planter" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = false   -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "models/pot/pot.mdl"
ENT.DefaultWaterLevel = 180
ENT.MaxWaterLevel = 180
ENT.frames = 100
ENT.frame = math.ceil(ENT.DefaultWaterLevel / ENT.MaxWaterLevel * ENT.frames) - 1
ENT.DefaultFrame = math.ceil(ENT.DefaultWaterLevel / ENT.MaxWaterLevel * ENT.frames) - 1
ENT.SeedLimit = 1
ENT.Seeds = {}
ENT.IsFertelized = true  
ENT.WaterLevelMaterial = Material("animatedtextures/circle_256px_100frames/circle_256px_100frames")
ENT.minHolderDetectionRange = Vector(40, 40, 20)
ENT.maxHolderDetectionRange = Vector(-30, -40, -10)

function ENT:UpdateFrame(name, old, new) 
    self.frame = math.ceil(new / self.MaxWaterLevel * self.frames) - 1
    self:UpdateDrawWaterDelegate()
end

function ENT:UpdateDraining(name, old, new) 
    if #self.Seeds > 0 and old == 0 and new > 0 then 
        table.insert(WaterDrainingEntities, 1, self) 
        print("Added "..self:GetClass().." To Drain Update")
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "WaterLevel")

    if CLIENT then
        self:NetworkVarNotify("WaterLevel", self.UpdateFrame)
    end

    if SERVER then
        self:NetworkVarNotify("WaterLevel", self.UpdateDraining)
    end
end

