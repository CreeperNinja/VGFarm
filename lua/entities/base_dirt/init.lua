AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("modules/RadialProgressBar.lua")
include("shared.lua")

AddCSLuaFile("sh_vgfarm.lua")
local VGFarm = include("sh_vgfarm.lua")
local min = math.min

sound.Add({
    name = "Dirt.Used",
    channel = CHAN_STATIC,
    volume = 1.0,
    level = 65,
    pitch = {95,105},
    sound = {
        "dirt/dirt1.ogg",
        "dirt/dirt2.ogg"
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
    self:SetDirtAmount(VGFarmConfig.DefaultDirtAmount)
    self:SetUseType(SIMPLE_USE) -- or CONTINUOUS_USE if needed
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    VGFarmUtils.SmartPrint(self:GetDirtAmount().." Dirt")
end

local planterClass = "base_planter"
function ENT:TouchedPlanter(ent)    
    if not VGFarmUtils.IsDirectChildOrSame(ent, planterClass) then return end
    
    local selfDirtAmount = self:GetDirtAmount()
    local planterDirtAmount = ent:GetDirtAmount()
    local planterMaxDirtAmount = ent.SeedLimit
    
    --If planter is full then stop interaction
    if planterDirtAmount >= planterMaxDirtAmount then print("Soiling skipped") return end

    local totalAdded = selfDirtAmount + planterDirtAmount
    local planterNewAmount = min(totalAdded, planterMaxDirtAmount)

    ent:SetDirtAmount(planterNewAmount)
    ent:EmitSound("Dirt.Used")

    local usedAmount = planterNewAmount - planterDirtAmount
    
    local newAmount = selfDirtAmount - usedAmount
    if newAmount > 0 then
        self:SetDirtAmount(newAmount)
        return
    end
    self:SetDirtAmount(0)
    self:Remove() -- Absorbed completely
end

--Move Water Amount to planter
function ENT:StartTouch(ent)
    self:TouchedPlanter(ent)   
end
