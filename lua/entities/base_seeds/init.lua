AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local print = print
local Clamp = math.Clamp
local random = math.random

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
    self:SetSeedAmount(self.DefaultSeedAmount)
    self:SetColor(HSVToColor(40,0.5,random(40,60)/100))
    self:PrintTest()
end

function ENT:TouchedSeeds(ent)
    if ent:GetClass() ~= self:GetClass() then return end
    
    local selfAmount = self:GetSeedAmount()
    local selfMax = self.MaxSeedAmount
    local entAmount = ent:GetSeedAmount()
    
    //If The Other Seed Pack Has No Remaining Seeds OR Pack Is Already Full Then Skip 
    if entAmount <= 0 or selfAmount == selfMax then print("One Of The Entities Has Skipped Seed Calculation") return end
    
    -- Prevent both entities from trying to merge at the same time - only the newer one will merge into the older
    if self:EntIndex() > ent:EntIndex() then print("One Of The Entities Has Disabled It's Merge Behaviour") return end
    
    local total = selfAmount + entAmount
    
    local newAmount = math.min(total, selfMax)
    self:SetSeedAmount(newAmount)
    
    if total > selfMax then
        local entNewAmount = total - selfMax
        ent:SetSeedAmount(entNewAmount)
    else
        ent:SetSeedAmount(0)
        ent:Remove() -- Absorbed completely
    end
end

local planterClass = "base_planter"
function ENT:TouchedPlanter(ent)
    if not VGFarmUtils.IsDirectChildOrSame(ent, planterClass) then return end
    
    //If planter is full
    if not ent:CanAddSeeds() then print("Seeding skipped") return end
    print("Touched A planter")
    ent:AddSeeds(self:GetClass(), 1)
    local newSeedAmount = self:GetSeedAmount() - 1
    if newSeedAmount <= 0 then
        print("Removing Seeds")
        self:Remove()
        return
    end
    self:SetSeedAmount(newSeedAmount)
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end
    self:TouchedSeeds(ent)
    self:TouchedPlanter(ent)
end
