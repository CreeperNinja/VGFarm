VGFarmClientConfig = VGFarmClientConfig or {}

--Draw Distance Culling 
VGFarmClientConfig.fadeStart = 200
VGFarmClientConfig.fadeStartSqr = VGFarmClientConfig.fadeStart * VGFarmClientConfig.fadeStart --Do Not Change
VGFarmClientConfig.maxDrawDistance = 500
VGFarmClientConfig.maxDrawDistanceSqr = VGFarmClientConfig.maxDrawDistance * VGFarmClientConfig.maxDrawDistance --Do Not Change

--Colors
VGFarmClientConfig.WaterBarColor = Color(25, 150, 225)
VGFarmClientConfig.DirtBarColor = Color(150, 100, 50)
VGFarmClientConfig.TextColor = Color(255, 255, 255)
VGFarmClientConfig.TextOutlineColor = Color(0, 0, 0)

return VGFarmClientConfig