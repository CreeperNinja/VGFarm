AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--Collection of all planters that will have the growth and draining updates
WaterDrainingEntities = {}
WaterDrainingEntitiesCount = 0

function ENT:Initialize()
    self:SetModel(self.Model) -- Sets the model for the Entity.
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.
    local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.
    if phys:IsValid() then -- Checks if the physics object is valid.
        phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
    end
    self:SetWaterAmount(self.DefaultWaterAmount)
end

--time it takes to update drain and growth in seconds (shorther time will send more net massages, while longer time will seem to be less responsive)
local drainUpdateSpeed = 5

local drainSpeed = 1
local drainAmount = 1

local growthAmount = 5

function ENT:IsInDrainingList()
    return WaterDrainingEntities[self] ~= nil 
end

function ENT:AddToDrainingList()
    if not self:IsInDrainingList() then
        WaterDrainingEntities[self] = true 
        WaterDrainingEntitiesCount = WaterDrainingEntitiesCount + 1
        VGFarmUtils.SmartPrint("Added "..self:GetClass().." To Drain Update")
    end
end

--Currently not in use
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
        local newIndex = table.insert(self.Seeds, {seedType = type, growProgress = 0})
        self.Seeds[newIndex].index = newIndex
    end
    self:AddToDrainingList()
end


function ENT:SpawnEmpyCropHolder()
    local crop = ents.Create("base_cropHolder")
    crop:SetPos(self:GetPos() + self:GetForward() * 50)
    crop:Spawn()
    crop:Activate()
    return crop
end

local function RemoveFromDraining(planter)
    WaterDrainingEntities[planter] = nil
    WaterDrainingEntitiesCount = WaterDrainingEntitiesCount - 1
end

function ENT:SpawnCrops(cropHashMap)
    local cropHolderEntity = VGFarmUtils.GetNearbyEntityInBox(self:GetPos() + self:GetForward() * 50, self.minHolderDetectionRange, self.maxHolderDetectionRange, "base_cropholder")
    if cropHolderEntity == nil then cropHolderEntity = self:SpawnEmpyCropHolder() end
    cropHolderEntity:AddCrops(cropHashMap)
end

function ENT:GrowSeeds(planterSeedsToUpdate)
    if #self.Seeds <= 0 then return end
    
    --optimization
    local lastCheckedType = nil 
    local seedENT = nil 
    local cropsToSpawn = {}
    local cropsToSpawnCount = 0

    --Internal
    local totalSeeds = #self.Seeds
    local seedCount = #self.Seeds

    for i = 0, totalSeeds - 1 do
        local key = totalSeeds - i
        local seed = self.Seeds[key]

        --optimization
        if lastCheckedType ~= seed.seedType then
            seedENT = scripted_ents.Get(seed.seedType)
            lastCheckedType = seed.seedType 
        end
        
        seed.growProgress = seed.growProgress + growthAmount

        --Finished Growing
        if seed.growProgress >= seedENT.GrowTime then 
            seedCount = seedCount - 1
            
            --adds to visual update
            planterSeedsToUpdate.count = VGFarmUtils.TableSafeCreate(planterSeedsToUpdate.content, self, {}, planterSeedsToUpdate.count)
            planterSeedsToUpdate.content[self][i + 1] = {0, key} --optianally use -1 to indicate not rendering
            
            --adds to crops spawn queue
            cropsToSpawnCount = VGFarmUtils.TableSafeCreate(cropsToSpawn, seedENT.CropClassName, 0, cropsToSpawnCount)
            cropsToSpawn[seedENT.CropClassName] = cropsToSpawn[seedENT.CropClassName] + seedENT:GetRandomCropAmount(self.IsFertelized)

            table.remove(self.Seeds, key)
            continue 
        end

        local previousGrowthPercent = math.floor(VGFarmUtils.GetPercent(seed.growProgress - growthAmount, seedENT.GrowTime))
        local currentGrowthPercent = math.floor(VGFarmUtils.GetPercent(seed.growProgress, seedENT.GrowTime))
        
        --if the growth percent is the same, don't send an update
        if previousGrowthPercent ~= currentGrowthPercent then
            planterSeedsToUpdate.count = VGFarmUtils.TableSafeCreate(planterSeedsToUpdate.content, self, {}, planterSeedsToUpdate.count)
            table.insert(planterSeedsToUpdate.content[self], {currentGrowthPercent, seed.index})
        else
            VGFarmUtils.SmartPrint(seed.seedType .." Skipped Growth Visual Update")
        end
    end

    if cropsToSpawnCount > 0 then self:SpawnCrops(cropsToSpawn) end

    if seedCount > 0 then return end

    VGFarmUtils.SmartPrint("No More Seeds Left To Grow")
    RemoveFromDraining(self)
    planterSeedsToUpdate.content[self] = nil
    planterSeedsToUpdate.count = planterSeedsToUpdate.count - 1
    self:ResetSeedProgress()
end

util.AddNetworkString("SendSeedGrowthProgressToClient")
util.AddNetworkString("SendResetSeedProgressToClient")

function ENT:ResetSeedProgress()
    net.Start("SendResetSeedProgressToClient")
    net.WriteEntity(self)
    net.Broadcast()
end

local function SendSeedGrowthProgressToClient(planterSeedsToUpdate)
    net.Start("SendSeedGrowthProgressToClient")
    VGFarmUtils.SmartNetUIntWrite(planterSeedsToUpdate.count)

    for planter, seeds in pairs(planterSeedsToUpdate.content) do
        net.WriteEntity(planter)
        VGFarmUtils.SmartNetUIntWrite(#seeds)
        for key, seed in pairs(seeds) do
            VGFarmUtils.SmartNetUIntWrite(seed[2])
            VGFarmUtils.SmartNetUIntWrite(seed[1])
        end
    end
    net.Broadcast()
end

timer.Create("DrainWater_Global", drainUpdateSpeed, 0, function()

    if WaterDrainingEntitiesCount == 0 then return end
    local planterSeedsToUpdate = {count = 0, content = {}}
    
    for planter, isDraining in pairs(WaterDrainingEntities) do

        --if planter no longer exists, remove it from updates
        if not IsValid(planter) then
            RemoveFromDraining(planter)
            VGFarmUtils.SmartPrint("Removed Invalid Entity From Drain Update")
            continue
        end

        local WaterAmount = planter:GetWaterAmount()
        WaterAmount = WaterAmount - drainAmount * drainSpeed
        if WaterAmount <= 0 then
            WaterAmount = 0
            RemoveFromDraining(planter)
            VGFarmUtils.SmartPrint("Entity " .. planter:EntIndex() .. " finished draining.")
        end
        planter:GrowSeeds(planterSeedsToUpdate)
        planter:SetWaterAmount(WaterAmount)
    end
    
    if WaterDrainingEntitiesCount == 0 or planterSeedsToUpdate.count <= 0 then return end
    SendSeedGrowthProgressToClient(planterSeedsToUpdate)
end)


