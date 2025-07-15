AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

WaterDrainingEntities = {}

function ENT:Initialize()
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
local drainUpdateSpeed = 5

local drainSpeed = 1
local drainAmount = 1

local growthAmount = 5

function ENT:IsInDrainingList()
    if WaterDrainingEntities[self] then return true end
    return false
end

function ENT:AddToDrainingList()
    if not self:IsInDrainingList() then
        WaterDrainingEntities[self] = true 
    end
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
    self:AddToDrainingList()
    print("Added "..self:GetClass().." To Drain Update")
end

function ENT:SpawnCrop(entClass, amount, cropHolderEntity)
    local crop = ents.Create("base_crop")
    crop.CropHolder = entClass.CropClassName 
    crop.CropAmount = amount
    crop:SetPos(self:GetPos() + self:GetRight() + self:GetUp() * 30)
    crop:Spawn()
    crop:Activate()
end

function ENT:SpawnEmpyCropHolder()
    local crop = ents.Create("base_cropholder")
    crop:SetPos(self:GetPos() + self:GetForward() * 50)
    crop:Spawn()
    crop:Activate()
    return crop
end

function ENT:SpawnCrops(cropHashMap)
    local cropHolderEntity = VGFarmUtils.GetNearbyEntityInBox(self:GetPos() + self:GetForward() * 50, self.minHolderDetectionRange, self.maxHolderDetectionRange, "base_cropholder")
    if cropHolderEntity == nil then cropHolderEntity = self:SpawnEmpyCropHolder() end
    cropHolderEntity:AddCrops(cropHashMap)
    print("Spawned And Added Crops")
end

function ENT:GrowSeeds(planter)
    if #self.Seeds <= 0 then return end

    --optimization
    local lastCheckedType = nil 
    local seedENT = nil 
    local cropsToSpawn = {}
    local cropsToSpawnCount = 0

    --growth code
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

        --code when finished growing
        if not cropsToSpawn[seedENT.CropClassName] then 
            cropsToSpawn[seedENT.CropClassName] = 0 
            cropsToSpawnCount = cropsToSpawnCount + 1
        end
        cropsToSpawn[seedENT.CropClassName] = cropsToSpawn[seedENT.CropClassName] + seedENT:GetRandomCropAmount(self.IsFertelized)
        self.Seeds[key] = nil 
    end

    if cropsToSpawnCount > 0 then
        self:SpawnCrops(cropsToSpawn)
    end

    if #self.Seeds <= 0 then WaterDrainingEntities[planter] = nil end
end


timer.Create("DrainWater_Global", drainUpdateSpeed, 0, function()

    for planter, isDraining in pairs(WaterDrainingEntities) do

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


