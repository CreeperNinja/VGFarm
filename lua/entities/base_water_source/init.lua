AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local min = math.min

sound.Add({
    name = "Water.Used",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 65,
    pitch = {95,105},
    sound = {
        "water/water1.ogg",
        "water/water2.ogg"
    }
})

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
    self:SharedInitialize()
end

function ENT:TouchedWater(ent)
    if ent:GetClass() ~= self:GetClass() then return end
    
    local selfAmount = self:GetWaterAmount()
    local selfMax = self.MaxWaterAmount
    local entAmount = ent:GetWaterAmount()
    local entMax = ent.MaxWaterAmount
    
    --If The Other Water Source Has No Remaining Water OR Water Is Already Full Then Skip 
    if entAmount <= 0 or selfAmount == selfMax then print("One Of The Entities Has Skipped Water Calculation") return end
    
    -- Prevent both entities from trying to merge at the same time - only the newer one will merge into the older
    if self:EntIndex() > ent:EntIndex() then print("One Of The Entities Has Disabled It's Merge Behaviour") return end
    
    local total = selfAmount + entAmount
    
    local newAmount = math.min(total, selfMax)
    self:SetWaterAmount(newAmount)
    
    if total > selfMax then
        local entNewAmount = total - selfMax
        ent:SetWaterAmount(entNewAmount)
    else
        ent:SetWaterAmount(0)
        ent:Remove() -- Absorbed completely
    end
end

local planterClass = "base_planter"
function ENT:TouchedPlanter(ent)    
    if not VGFarmUtils.IsDirectChildOrSame(ent, planterClass) then return end
    
    local selfAmount = self:GetWaterAmount()
    local selfMax = self.MaxWaterAmount
    local planterAmount = ent:GetWaterAmount()
    local planterMax = ent.MaxWaterAmount
    
    --If planter is full then stop interaction
    if planterAmount >= planterMax then print("Watering skipped") return end

    local totalAdded = selfAmount + planterAmount
    local planterNewAmount = min(totalAdded, planterMax)

    ent:SetWaterAmount(planterNewAmount)
    ent:EmitSound("Water.Used")

    local usedAmount = planterNewAmount - planterAmount
    
    local newAmount = selfAmount - usedAmount
    if newAmount > 0 then
        self:SetWaterAmount(newAmount)
        return
    end
    self:SetWaterAmount(0)
    print("Watering Can Empty")
    self:Remove() -- Absorbed completely
end

--Move Water Amount to planter
function ENT:StartTouch(ent)
    self:TouchedWater(ent)
    self:TouchedPlanter(ent)   
end
