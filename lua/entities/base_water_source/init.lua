AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local min = math.min

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
    self:SetWaterLevel(self.DefaultWaterLevel)

end

//Move Water Amount to planter
function ENT:StartTouch(ent)
    if not IsValid(ent) or ent:GetClass() ~= "base_planter" then return end
    
    local selfAmount = self:GetWaterLevel()
    local selfMax = self.MaxWaterLevel
    local entAmount = ent:GetWaterLevel()
    local entMax = ent.MaxWaterLevel
    
    //If planter is full
    if entAmount >= entMax then print("Watering skipped") return end

    local total = selfAmount + entAmount

    local entNewAmount = min(total, selfMax)

    ent:SetWaterLevel(entNewAmount)
    
    if total > selfMax then
        local newAmount = total - selfMax
        print("Planter now has "..entNewAmount.." | Watering can now has "..newAmount)
        self:SetWaterLevel(newAmount)
    else
        self:SetWaterLevel(0)
        print("Watering Can Empty")
        self:Remove() -- Absorbed completely
    end
end
