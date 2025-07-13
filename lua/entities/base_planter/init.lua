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

--time it takes to update drain and growth in seconds (shorther time will send more net massages, while longer time will seem to be less responsive)
local drainUpdateSpeed = 2

local drainSpeed = 1
local drainAmount = 1

local growthAmount = 1

function ENT:IsInDrainingList()
    if WaterDrainingEntities[self] then return true end
    return false
end

function ENT:AddToDrainingList()
    if not self:IsInDrainingList() then
        WaterDrainingEntities[self] = true 
    end
end

function ENT:SpawnCrop(entClass)
    local crop = ents.Create("base_crop")
    crop.CropHolder = entClass.CropClassName 
    crop.CropAmount = entClass:GetRandomCropAmount(self.IsFertelized)
    print("Spawning "..crop.CropAmount.." "..entClass.CropClassName)
    crop:SetPos(self:GetPos() + self:GetRight() + self:GetUp() * 30)
    crop:Spawn()
    crop:Activate()
    if self.IsFertelized then print("Was Fertelized") return end
    print("Was Not Fertelized")
end

function ENT:CanAddSeeds()
    if self.Seeds ~= nil and #self.Seeds >= self.SeedLimit then print("Pot Already Full") return false end
    print("Can Add Seeds")
    return true
end

function ENT:ReturnAvailableSpace()
    if self.Seeds == nil then print("Error") return 0 end
    return self.SeedLimit - #self.Seeds
end

function ENT:AddSeeds(type, amount)
    for i = 1, amount do
        print("Adding To ".. i)
        table.insert(self.Seeds, {seedType = type, growProgress = 0})
    end
    print("Planter now has ".. #self.Seeds .." Seeds")
    self:AddToDrainingList()
    print("Added "..self:GetClass().." To Drain Update")
end

function ENT:GrowSeeds(planter)
    if #self.Seeds <= 0 then return end

    --optimization
    local lastCheckedType = nil 
    local seedENT = nil 

    print("-- Planter now has ".. #self.Seeds .." Seeds --")
    for key, seed in pairs(self.Seeds) do
        seed.growProgress = seed.growProgress + growthAmount

        --optimization
        if lastCheckedType ~= seed.seedType then
            seedENT = scripted_ents.Get(seed.seedType)
            lastCheckedType = seed.seedType 
        end

        print(seed.seedType.." "..seed.growProgress.." / "..seedENT.GrowTime)
        --check if seed is still growing
        if seed.growProgress < seedENT.GrowTime then continue end

        print(seed.seedType.." Finished Growing")
        self:SpawnCrop(seedENT)
        self.Seeds[key] = nil 
    end

    if #self.Seeds <= 0 then WaterDrainingEntities[planter] = nil end
end

timer.Create("DrainWater_Global", drainUpdateSpeed, 0, function()

    for planter, isDraining in pairs(WaterDrainingEntities) do
        print("Entity Drain Updated")

        if not IsValid(planter) then
            print("Removed Invalid Entity ".. planter)
            WaterDrainingEntities[planter] = nil
            continue
        end

        local waterLevel = planter:GetWaterLevel()
        waterLevel = waterLevel - drainAmount * drainSpeed
        if waterLevel <= 0 then
            waterLevel = 0
            WaterDrainingEntities[planter] = nil
            print("Entity " .. planter:EntIndex() .. " finished draining.")
        end
        planter:GrowSeeds(planter)
        planter:SetWaterLevel(waterLevel)
    end

end)


