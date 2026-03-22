ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Dirt" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = true  -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Model = "models/sack/sack.mdl"

function ENT:UpdateDirtVisual(name, old, new)
    if new ~= old and new > 0 then 
        dirtFloat = new / VGFarmConfig.DefaultDirtAmount
        self:UpdateDirt(dirtFloat, new)
    end
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "DirtAmount")

    if CLIENT then
        self:NetworkVarNotify("DirtAmount", self.UpdateDirtVisual)
    end
end
