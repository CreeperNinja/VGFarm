include("shared.lua")
local VGFarm = include("sh_vgfarm.lua")

surface.CreateFont("CropText", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true
})

local function RecieveHolderData()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent.Crops = ent.Crops or {}
    local differentCropTypes = net.ReadUInt(VGFarm.CropBitEncoder)
    for i = 1, differentCropTypes do
        local cropType = VGFarm.SmartNetCropRead()
        local amount = VGFarmUtils.SmartNetUIntRead()
        ent.Crops[cropType] = amount
    end
end

net.Receive("SendHolderData", RecieveHolderData)

function ENT:Initialize()
    net.Start("ClientReadyForCrops")
    net.WriteEntity(self)
    net.SendToServer()
end

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos() + Vector(0, 0, 20)

    cam.Start3D2D(pos, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)
        local y = 0
        for cropType, amount in pairs(self.Crops) do
            draw.SimpleText(cropType .. ": " .. amount, "CropText", 0, y, color_white, TEXT_ALIGN_CENTER)
            y = y - 24
        end
    cam.End3D2D()
end