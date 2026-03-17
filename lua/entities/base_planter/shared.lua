ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Base Planter" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = false   -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--Model
ENT.Model = "models/planter_small/planter_small.mdl"

--Water Amount
ENT.DefaultWaterAmount = 0
ENT.MaxWaterAmount = 180

--Water Amount Visuals
ENT.frames = 100
ENT.frame = math.ceil(ENT.DefaultWaterAmount / ENT.MaxWaterAmount * ENT.frames) - 1
ENT.DefaultFrame = math.ceil(ENT.DefaultWaterAmount / ENT.MaxWaterAmount * ENT.frames) - 1
ENT.WaterAmountMaterial = Material("animatedtextures/circle_256px_100frames/circle_256px_100frames")

--Planter Mechanics
ENT.SeedLimit = 1
ENT.Seeds = {}
ENT.IsFertelized = true  
ENT.DefaultDirtAmount = 0
ENT.minHolderDetectionRange = Vector(40, 40, 20)
ENT.maxHolderDetectionRange = Vector(-30, -40, -10)

--Planter Mechanics Visuals
ENT.SeedInfoPerRow = 3

--Updates Water Amount Image Frame
function ENT:UpdateFrame(name, old, new) 
    self.frame = math.ceil(new / self.MaxWaterAmount * self.frames) - 1
    self:UpdateDrawWaterDelegate()
end

--Updates Water Amount Image Frame
function ENT:UpdateDirtVisual(name, old, new) 
    if old == 0 and new > 0 then
        self:SetBodygroup(1, 1)
        
    elseif old > 0 and new == 0 then
        self:SetBodygroup(1, 0)
    end
end

--Adds Planter To Draining Cycle if eligible 
function ENT:UpdateDraining(name, old, new) 
    if #self.Seeds > 0 and old == 0 and new > 0 then 
        WaterDrainingEntities[self] = true 
        print("Added "..self:GetClass().." To Drain Update")
    end
end

--Netwrok Vars / Notifiers
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "WaterAmount")
    self:NetworkVar("Int", 1, "DirtAmount")

    if CLIENT then
        self:NetworkVarNotify("WaterAmount", self.UpdateFrame)
        self:NetworkVarNotify("DirtAmount", self.UpdateDirtVisual)
    end

    if SERVER then
        self:NetworkVarNotify("WaterAmount", self.UpdateDraining)
    end
end

function ENT:SharedInitialize()
    local configSettings = VGFarmConfig.Planter[self:GetClass()]
    self.MaxWaterAmount = configSettings.MaxWaterAmount or 180
end