include("shared.lua")
local RadialProgressBar = include("modules/RadialProgressBar.lua")

--Fonts
surface.CreateFont("DirtTextFont", {
    font = "Tahoma",
    size = 64,
    weight = 50,
    antialias = true
})

--Localized functions
local Clamp = math.Clamp

--Dirt Bar
local dirtBarRadius = 150
local dirtBarDrawYOffset = nil 
local constantYOffset = 20
local dirtDrawScale = 0.07

local textAllign = TEXT_ALIGN_CENTER

function ENT:UpdateDirt(newAmountFloat, newAmount)
    self.dirtBar:BuildUVs(dirtBarRadius, newAmountFloat)
    self:UpdateDirtText(newAmount)
end

function ENT:UpdateDirtText(newAmount)
    self.dirtText = newAmount.." / ".. VGFarmConfig.DefaultDirtAmount
end

function ENT:SetColors()
    self.dirtColor = Color(VGFarmClientConfig.DirtBarColor.r, VGFarmClientConfig.DirtBarColor.g, VGFarmClientConfig.DirtBarColor.b, 255)
    self.textColor = Color(VGFarmClientConfig.TextColor.r, VGFarmClientConfig.TextColor.g, VGFarmClientConfig.TextColor.b, 255)
    self.outlineColor = Color(VGFarmClientConfig.TextOutlineColor.r, VGFarmClientConfig.TextOutlineColor.g, VGFarmClientConfig.TextOutlineColor.b, 255)
end

function ENT:Initialize()
    self:SetColors()
    self.dirtBar = RadialProgressBar:New(dirtBarRadius, 1, self.dirtColor)
    self:UpdateDirtText(VGFarmConfig.DefaultDirtAmount)

    local modelMins, modelMaxs = self:GetModelBounds()
    if not dirtBarDrawYOffset then dirtBarDrawYOffset = Vector(0, 0, modelMaxs.z + (dirtBarRadius * dirtDrawScale / 2) + constantYOffset) end
end

function ENT:Draw()
    self:DrawModel()
    
    local playerPos = LocalPlayer():GetPos()
    local dirtPos = self:GetPos()
    local distSqr = playerPos:DistToSqr(dirtPos)
    
    --Early Exit to not render info if too far away
    if distSqr > VGFarmClientConfig.maxDrawDistanceSqr then return end

    --Creates a constant horizontal view
    local yaw = (playerPos - dirtPos):Angle().y
    local drawAng = Angle(0, yaw + 90, 90)

    --Fade effect when getting further
    local alpha = 255
    if distSqr > VGFarmClientConfig.fadeStartSqr then
        local frac = Clamp((VGFarmClientConfig.maxDrawDistanceSqr / distSqr) / (distSqr / VGFarmClientConfig.fadeStartSqr), 0, 1)
        alpha = alpha * frac
    end

    self.dirtColor.a = alpha
    self.textColor.a = alpha
    self.outlineColor.a = alpha
    
    cam.Start3D2D(dirtPos + dirtBarDrawYOffset , drawAng, dirtDrawScale)
        self.dirtBar:ExternalDraw()
        draw.SimpleTextOutlined(self.dirtText, "DirtTextFont", 0, 0, self.textColor, textAllign, textAllign, 3, self.outlineColor)
    cam.End3D2D()
end