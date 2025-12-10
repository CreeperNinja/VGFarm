ENT.Type = "anim" -- Sets the Entity type to 'anim', indicating it's an animated Entity.
ENT.Base = "base_seeds"
ENT.PrintName = "Garlic Seeds" -- The name that will appear in the spawn menu.
ENT.Author = "Void" -- The author's name for this Entity.
ENT.Category = "VGFarm" -- The category for this Entity in the spawn menu.
ENT.Spawnable = true -- Specifies whether this Entity can be spawned by players in the spawn menu.
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--Pack
ENT.xGrid = 7
ENT.yGrid = 4
ENT.MaxGridAmount = ENT.xGrid * ENT.yGrid
ENT.MaxSeedAmount = ENT.MaxGridAmount * 2
ENT.SeedIcon = Material("icons/seedPacks/tomatoIcon.png")
ENT.DefaultSeedAmount = 6 -- default amount

--Seeds
ENT.GrowTime = 300
ENT.CropClassName = "Garlics"
ENT.CropAmount = 1
ENT.CropMaxAmount = 3
