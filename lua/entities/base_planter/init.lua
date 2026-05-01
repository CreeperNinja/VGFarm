AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("modules/RadialProgressBar.lua")
include("shared.lua")

--Collection of all planters that will have the growth and draining updates
WaterDrainingEntities = {}
WaterDrainingEntitiesCount = 0

sound.Add({
    name = "Plant.Grown",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 65,
    pitch = {95,105},
    sound = {
        "plant/plant1.ogg",
        "plant/plant2.ogg"
    }
})

function ENT:Initialize()
    self:SetModel(self.Model) -- Sets the model for the Entity.
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the Entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the Entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS ) -- Makes the Entity solid, allowing for collisions.
    local phys = self:GetPhysicsObject() -- Retrieves the physics object of the Entity.
    if phys:IsValid() then -- Checks if the physics object is valid.
        phys:Wake() -- Activates the physics object, making the Entity subject to physics (gravity, collisions, etc.).
    end
    self:SharedInitialize()
    self:SetDirtAmount(self.DefaultDirtAmount)
    self:SetUseType(SIMPLE_USE)
    self:CreateSeedInventory()
end

local lastSavedPlanterUpdateSpeed = VGFarmConfig.planterUpdateSpeed

function ENT:CreateSeedInventory()
    for i = 1, self.SeedLimit do
        self.Seeds[i] = nil 
    end
    self.UsedSeedSlots = 0
end

function ENT:ReturnAvailableSpace()
    return self.SeedLimit - self.UsedSeedSlots
end

function ENT:IsInDrainingList()
    return WaterDrainingEntities[self] ~= nil 
end

function ENT:TryAddToDrainingList(seedCount, waterAmount)
    if seedCount > 0 and waterAmount > 0 then
        self:AddToDrainingList()
    end
end

function ENT:AddToDrainingList()
    if not self:IsInDrainingList() then
        WaterDrainingEntities[self] = true 
        WaterDrainingEntitiesCount = WaterDrainingEntitiesCount + 1
        VGFarmUtils.SmartPrint("Added "..self:GetClass().." To Drain Update | Total: "..WaterDrainingEntitiesCount)
    end
end

function ENT:AddSeeds(type, amount)
    local lastFoundSlot = 1
    for i = 1, amount do
        local slot = self:FindFreeSlot(lastFoundSlot)
        if not slot then lastFoundSlot = lastFoundSlot + 1 continue end

        self.Seeds[slot] = {
            seedType = type,
            growProgress = 0
        }
        self.UsedSeedSlots = self.UsedSeedSlots + 1
        lastFoundSlot = slot
    end

    self:TryAddToDrainingList(amount, self:GetWaterAmount())
end

function ENT:RemoveSeed(index)
    self.Seeds[index] = nil 
    self.UsedSeedSlots = self.UsedSeedSlots - 1
end

function ENT:FindFreeSlot(startingIndex)
    for i = startingIndex or 1, self.SeedLimit do
        if self.Seeds[i] == nil then return i end
    end
    return nil
end

function ENT:FindUsedSlot(startingIndex)
    for i = startingIndex or 1, self.SeedLimit do
        if self.Seeds[i] ~= nil then 
            return i end
    end
    return nil
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

hook.Add("VGFarm_CropsSpawned", "Example", function(planter, cropHashMap, cropHolderEntity)
    print(planter:GetName().. " Has Grown Crops And Placed It In "..cropHolderEntity:GetName())
    for cropName, cropAmount in pairs(cropHashMap) do
        print(cropName..": "..cropAmount)
    end
end)

function ENT:SpawnCrops(cropHashMap)
    local cropHolderEntity = VGFarmUtils.GetNearbyEntityInBox(self:GetPos() + self:GetForward() * 50, self.minHolderDetectionRange, self.maxHolderDetectionRange, "base_cropholder")
    if cropHolderEntity == nil then cropHolderEntity = self:SpawnEmpyCropHolder() end
    cropHolderEntity:AddCrops(cropHashMap)
    self:EmitSound("Plant.Grown")
    -- passes the planter that spawned the crops, the crops hashmap, and the entity that spawned
    hook.Run("VGFarm_CropsSpawned", self, cropHashMap, cropHolderEntity)

end

function ENT:GrowSeeds(planterSeedsToUpdate)
    if self.UsedSeedSlots <= 0 then return end
    
    --optimization
    local lastCheckedType = nil 
    local seedENT = nil 
    local cropsToSpawn = {}
    local cropsToSpawnCount = 0

    --Internal
    local totalSeeds = self.UsedSeedSlots
    local seedCount = self.UsedSeedSlots
    local lastFoundSlot = 0

    for i = 1, totalSeeds do
        --Finding the First Empty Seed Slot
        local slot = self:FindUsedSlot(lastFoundSlot + 1)

        local key = slot
        local seed = self.Seeds[key]

        --optimization
        if lastCheckedType ~= seed.seedType then
            seedENT = scripted_ents.Get(seed.seedType)
            lastCheckedType = seed.seedType 
        end
        
        seed.growProgress = seed.growProgress + VGFarmConfig.plantGrowthAmount * VGFarmConfig.planterUpdateSpeed
        --Finished Growing
        if seed.growProgress >= seedENT.GrowTime then 
            seedCount = seedCount - 1
            
            --adds to visual update
            planterSeedsToUpdate.count = VGFarmUtils.TableSafeCreate(planterSeedsToUpdate.content, self, {}, planterSeedsToUpdate.count)
            table.insert(planterSeedsToUpdate.content[self], {100, key})
            
            --adds to crops spawn queue
            cropsToSpawnCount = VGFarmUtils.TableSafeCreate(cropsToSpawn, seedENT.CropClassName, 0, cropsToSpawnCount)
            cropsToSpawn[seedENT.CropClassName] = cropsToSpawn[seedENT.CropClassName] + seedENT:GetRandomCropAmount(self.IsFertelized)

            self:RemoveSeed(key) 
            lastFoundSlot = slot
            continue 
        end

        local previousGrowthPercent = math.floor(VGFarmUtils.GetPercent(seed.growProgress - VGFarmConfig.plantGrowthAmount * VGFarmConfig.planterUpdateSpeed, seedENT.GrowTime))
        local currentGrowthPercent = math.floor(VGFarmUtils.GetPercent(seed.growProgress, seedENT.GrowTime))
        
        --Send Update only if growth percent changed
        if previousGrowthPercent ~= currentGrowthPercent then
            planterSeedsToUpdate.count = VGFarmUtils.TableSafeCreate(planterSeedsToUpdate.content, self, {}, planterSeedsToUpdate.count)
            table.insert(planterSeedsToUpdate.content[self], {currentGrowthPercent, key})
        else
            VGFarmUtils.SmartPrint(seed.seedType .." Skipped Growth Visual Update")
        end
        
        lastFoundSlot = slot
    end

    if totalSeeds ~= seedCount then
        local newDirtAmount = totalSeeds - (totalSeeds - seedCount)
        self:SetDirtAmount(newDirtAmount)
    end

    if cropsToSpawnCount > 0 then 
        self:SpawnCrops(cropsToSpawn) 
        
    end

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
        VGFarmUtils.SmartNetUIntWrite(#planterSeedsToUpdate.content[planter])
        PrintTable(planterSeedsToUpdate.content[planter])
        for key, seed in pairs(seeds) do
            VGFarmUtils.SmartNetUIntWrite(seed[2])
            VGFarmUtils.SmartNetUIntWrite(seed[1])
        end
    end
    net.Broadcast()
end

local function RunPlanterLogicOnAll() 
    if lastSavedPlanterUpdateSpeed ~= planterUpdateSpeed then
        lastSavedPlanterUpdateSpeed = planterUpdateSpeed
        timer.Adjust("PlanterLogic_Global", VGFarmConfig.planterUpdateSpeed, 0, RunPlanterLogicOnAll)
        return
    end
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
        WaterAmount = WaterAmount - VGFarmConfig.waterDrainAmount * VGFarmConfig.planterUpdateSpeed
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
end

timer.Create("PlanterLogic_Global", VGFarmConfig.planterUpdateSpeed, 0, RunPlanterLogicOnAll)

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    VGFarmUtils.SmartPrint(WaterDrainingEntities[self])
end
