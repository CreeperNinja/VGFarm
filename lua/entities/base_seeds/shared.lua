-- Defines the Entity's type, base, printable name, and author for shared access (both server and client)
ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_gmodentity" -- Specifies that this Entity is based on the 'base_gmodentity', inheriting its functionality.
ENT.PrintName = "Seeds" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = true -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.SeedAmount = 5 -- default amount
ENT.xGrid = 5
ENT.yGrid = 4
ENT.MaxSeedAmount = ENT.xGrid * ENT.yGrid
ENT.BlueGrid = 0
ENT.GreenGrid = 0
ENT.GrayGrid = 0
ENT.Model = "addons/VGFarm/models/seedPack2/seedPack2.mdl"
ENT.yGridOffset = 50
ENT.SeedIcon = Material("icons/seedPacks/questionMarkIcon.png")

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "SeedAmount")
    self:NetworkVar("Int", 1, "MaxSeedAmount")
    self:NetworkVar("Int", 2, "BlueGrid")
    self:NetworkVar("Int", 3, "GreenGrid")
    self:NetworkVar("Int", 4, "GrayGrid")
end

