AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local print = print
local Clamp = math.Clamp
local random = math.random

function ENT:UpdateGridCache(seedCount, maxSlots)

    local xGrid, yGrid = self.xGrid, self.yGrid
    local gridAmount = xGrid * yGrid
    //Calculate amount Exceeding the grid
    local blue = Clamp(seedCount - gridAmount, 0, gridAmount)
    self:SetBlueGrid(blue)

    //Calculate amount Filling the grid
    local green = Clamp(seedCount - blue, 0, gridAmount)
    self:SetGreenGrid(green)

    //Calculate amount Missing the grid
    local gray = Clamp(gridAmount - green - blue, 0, gridAmount)
    self:SetGrayGrid(gray)

    print("New Grid Cache: \r\n        Blue:"..blue.."\r\n        Green"..green.." \r\n        Gray"..gray)
end

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

    self:SetSeedAmount(self.SeedAmount)
    self:SetMaxSeedAmount(self.xGrid  * self.yGrid * 2)
    self:UpdateGridCache(self:GetSeedAmount(), self:GetMaxSeedAmount())
    self:SetColor(HSVToColor(40,0.5,random(40,60)/100))
end

function ENT:StartTouch(ent)
    if not IsValid(ent) or ent:GetClass() ~= self:GetClass() then return end
    
    local selfAmount = self:GetSeedAmount()
    local selfMax = self:GetMaxSeedAmount()
    local entAmount = ent:GetSeedAmount()

    //If The Other Seed Pack Has No Remaining Seeds OR Pack Is Already Full Then Skip 
    if entAmount <= 0 or selfAmount == selfMax then print("One Of The Entities Has Skipped Seed Calculation") return end

    -- Prevent both entities from trying to merge at the same time - only the newer one will merge into the older
    if self:EntIndex() > ent:EntIndex() then print("One Of The Entities Has Disabled It's Merge Behaviour") return end

    local entMax = ent:GetMaxSeedAmount()
    local total = selfAmount + entAmount

    -- Only combine if not both already full
    //if selfAmount < entMax or entAmount < entMax then end

    local newAmount = math.min(total, selfMax)
    self:SetSeedAmount(newAmount)
    self:UpdateGridCache(newAmount, selfMax)

    if total > selfMax then
        local entNewAmount = total - selfMax
        ent:SetSeedAmount(entNewAmount)
        ent:UpdateGridCache(entNewAmount, entMax)
    else
        ent:SetSeedAmount(0)
        ent:Remove() -- Absorbed completely
    end
end
