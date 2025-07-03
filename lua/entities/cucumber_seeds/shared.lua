-- Defines the Entity's type, base, printable name, and author for shared access (both server and client)
ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_seeds"
ENT.PrintName = "Cucumber Seeds" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = true -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.DefaultSeedAmount = 7 -- default amount
ENT.xGrid = 7
ENT.yGrid = 4
ENT.MaxGridAmount = ENT.xGrid * ENT.yGrid
ENT.MaxSeedAmount = ENT.MaxGridAmount * 2
ENT.CropClassName = "Cucumbers"
ENT.Model = "addons/VGFarm/models/seedPack2/seedPack2.mdl"
ENT.yGridOffset = 50
ENT.SeedIcon = Material("icons/seedPacks/cucumberIcon.png")
