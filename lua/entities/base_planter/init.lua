AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

WaterDrainingEntities = {}

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
    print("Spawned Entity with water level: "..self.DefaultWaterLevel)
    if self.DefaultWaterLevel > 0 then table.insert(WaterDrainingEntities, 1, self) end

end

local drainSpeed = 1
local drainAmount = 1

timer.Create("DrainWater_Global", drainSpeed, 0, function()

    for i = #WaterDrainingEntities, 1, -1 do
        local ent = WaterDrainingEntities[i]
        
        if not IsValid(ent) then
            print("Removed Invalid Entity ".. i)
            table.remove(WaterDrainingEntities, i)
            continue
        end

        local waterLevel = ent:GetWaterLevel()
        waterLevel = waterLevel - drainAmount
        if waterLevel <= 0 then
            waterLevel = 0
            table.remove(WaterDrainingEntities, i)
            print("Entity " .. ent:EntIndex() .. " finished draining.")
        end

        ent:SetWaterLevel(waterLevel)
        print("Water Level now is "..waterLevel)
    end

end)


