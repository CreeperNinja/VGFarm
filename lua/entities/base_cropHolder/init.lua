AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

AddCSLuaFile("sh_vgfarm.lua")
local VGFarm = include("sh_vgfarm.lua")


-- This will be called on both the Client and Server realms
function ENT:Initialize()
	-- Ensure code for the Server realm does not accidentally run on the Client
    self:SetModel(self.Model) -- Sets the model for the Entity.
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.
    local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.
    if phys:IsValid() then -- Checks if the physics object is valid.
        phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
    end
    self:SetUseType(SIMPLE_USE) -- or CONTINUOUS_USE if needed
    print("Spawned Crop Entity")
    self.ReadyForCrops = false 
end

util.AddNetworkString("ClientReadyForCrops")
util.AddNetworkString("SendHolderData")

function ENT:SendHolderData()
    if not self.ReadyForCrops then return end
    net.Start("SendHolderData")
    net.WriteEntity(self)
    net.WriteUInt(table.Count(self.Crops), VGFarm.CropBitEncoder)
    for cropType, amount in pairs(self.Crops) do
        VGFarm.SmartNetCropWrite(cropType)
        VGFarmUtils.SmartNetUIntWrite(amount)
    end
    net.Broadcast()
end

function ENT:AddCrops(cropHashMap)
    for cropType, amount in pairs(cropHashMap) do
        self.Crops[cropType] = (self.Crops[cropType] or 0) + amount
    end
    self:SendHolderData(ply)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    SVGFarm:AddCropsToPlayerInventory(activator, self.Crops)
    self:Remove()
end

net.Receive("ClientReadyForCrops", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or not ent.Crops then return end
    ent.ReadyForCrops = true
    ent:SendHolderData(ply)
end)
