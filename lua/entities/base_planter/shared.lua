-- Defines the Entity's type, base, printable name, and author for shared access (both server and client)
ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Base Planter" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = true -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Model = "addons/VGFarm/models/pot/pot.mdl"
ENT.Soiled = false
ENT.Watered = false
ENT.DefaultWaterLevel = 0
ENT.MaxWaterLevel = 180
ENT.frames = 100
ENT.DefaultFrame = ENT.DefaultWaterLevel / ENT.MaxWaterLevel * ENT.frames
ENT.WaterLevelMaterialPath = "spriteSheets/256_101_internal/256_101_internal"

function ENT:UpdateFrame(name, old, new) 
    local frame = math.ceil(new / self.MaxWaterLevel * self.frames)
    self.WaterLevelMaterial:SetInt("$frame", frame)
    print("Frame: "..frame)
end

function ENT:UpdateDraining(name, old, new) 
    if old == 0 and new > 0 then table.insert(WaterDrainingEntities, 1, self) end
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

