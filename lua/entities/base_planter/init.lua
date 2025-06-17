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

end

local drainSpeed = 1
local drainAmount = 1

function ENT:SpawnCrop(entClass)
    local crop = ents.Create(entClass.CropClassName)
    print("Spawning Crop")
    crop:SetPos(self:GetPos() + self:GetRight() + self:GetUp() * 30)
    crop:Spawn()
    crop:Activate()
end

function ENT:CanAddSeeds()
    if self.Seeds[1] ~= nil then print("Pot Already Full") return false end
    return true
end

function ENT:AddSeeds(type, amount)
    self.Seeds[1] = {type, 0}
    table.insert(WaterDrainingEntities, 1, self)
    print("Added "..self:GetClass().." To Drain Update")
end

function ENT:GrowSeeds(tableIndex)
    if self.Seeds[1] == nil then return end

    //adds progress to the seed
    self.Seeds[1][2] = self.Seeds[1][2] + 1
    print("New Seed Progress "..self.Seeds[1][2])
    local ent = scripted_ents.Get(self.Seeds[1][1])

    //If seed has reached full growth, remove it from pot, draining cycle, and spawn crop
    if self.Seeds[1][2] >= ent.GrowTime then 
        print(self.Seeds[1][1].." Finished Growing")
        self.Seeds[1] = nil
        self:SpawnCrop(ent)
        if tableIndex > 0 then
            table.remove(WaterDrainingEntities, tableIndex)
        end
    end
end

function ENT:GetWaterDrainAmount()
    return drainAmount
end

timer.Create("DrainWater_Global", drainSpeed, 0, function()
    for i = #WaterDrainingEntities, 1, -1 do
        local ent = WaterDrainingEntities[i]
        local tableIndex = i
        
        if not IsValid(ent) then
            print("Removed Invalid Entity ".. i)
            table.remove(WaterDrainingEntities, i)
            continue
        end

        local waterLevel = ent:GetWaterLevel()
        local drain = ent:GetWaterDrainAmount()
        waterLevel = waterLevel - drain
        if waterLevel <= 0 then
            waterLevel = 0
            table.remove(WaterDrainingEntities, i)
            tableIndex = 0
            print("Entity " .. ent:EntIndex() .. " finished draining.")
        end
        print(i)
        ent:GrowSeeds(tableIndex)
        ent:SetWaterLevel(waterLevel)
    end

end)


