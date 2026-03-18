local RadialProgressBar = {}
RadialProgressBar.__index = RadialProgressBar

local maxTriangleRadianAngle =  math.rad(45)
local defaultCircleMaterial = Material("icons/ui/circle512px.png")

local centerPoint = {x = 0, y = 0, u = 0.5, v = 0.5}

--default points every 45 degrees from top counter clockwise
local defaultUVPoints = {
    {x = 0, y = -1, u = 0.5, v = 0},
    {x = -1, y = -1, u = 0, v = 0},
    {x = -1, y = 0, u = 0, v = 0.5},
    {x = -1, y = 1, u = 0, v = 1},
    {x = 0, y = 1, u = 0.5, v = 1},
    {x = 1, y = 1, u = 1, v = 1},
    {x = 1, y = 0, u = 1, v = 0.5},
    {x = 1, y = -1, u = 1, v = 0},
}

function RadialProgressBar:BuildUVs(progressFloat)
    local sections = 8 * progressFloat
    local fullSections = math.floor(sections)
    local remainder = sections - fullSections

    local mesh = {}
    local index = 1

    --creates 45 degree polygons
    for i = 0, fullSections - 1 do
        local p1 = defaultUVPoints[i + 1]
        local p2 = defaultUVPoints[i + 2] or defaultUVPoints[1]

        mesh[index]     = centerPoint
        mesh[index + 1] = {
            x = p2.x * self.radius,
            y = p2.y * self.radius,
            u = p2.u,
            v = p2.v
        }
        mesh[index + 2] = {
            x = p1.x * self.radius,
            y = p1.y * self.radius,
            u = p1.u,
            v = p1.v
        }
        index = index + 3
    end

    --creates the last polygon if its not full
    if remainder > 0 then
        local p1 = defaultUVPoints[fullSections + 1]
        local p2 = defaultUVPoints[fullSections + 2] or defaultUVPoints[1]

        local lerped = {
            x = Lerp(remainder, p1.x * self.radius, p2.x * self.radius),
            y = Lerp(remainder, p1.y * self.radius, p2.y * self.radius),
            u = Lerp(remainder, p1.u, p2.u),
            v = Lerp(remainder, p1.v, p2.v)
        }

        mesh[index]     = centerPoint
        mesh[index + 1] = lerped
        mesh[index + 2] = {
            x = p1.x * self.radius,
            y = p1.y * self.radius,
            u = p1.u,
            v = p1.v
        }
    end

    return mesh
end

--Creates Radial UI Instance
function RadialProgressBar:New(radius, startingProgressFloat) --values between 0 and 1
    local self = setmetatable({}, RadialProgressBar)
    self.radialMaterial = defaultCircleMaterial
    self.radius = radius
    self.radialBarShapeTable = self:BuildUVs(startingProgressFloat)
    return self
end

function RadialProgressBar:Draw()
        surface.SetMaterial(self.radialMaterial)
        surface.DrawPoly(self.radialBarShapeTable)
end

return RadialProgressBar
