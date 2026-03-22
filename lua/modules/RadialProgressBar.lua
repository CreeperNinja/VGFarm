local RadialProgressBar = {}
RadialProgressBar.__index = RadialProgressBar

local defaultCircleMaterial = Material("icons/ui/circle512px.png")
local defaultColor = Color(255,255,255,255)

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

function RadialProgressBar:BuildUVs(radius, progressFloat)
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
            x = p2.x * radius,
            y = p2.y * radius,
            u = p2.u,
            v = p2.v
        }
        mesh[index + 2] = {
            x = p1.x * radius,
            y = p1.y * radius,
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
            x = Lerp(remainder, p1.x * radius, p2.x * radius),
            y = Lerp(remainder, p1.y * radius, p2.y * radius),
            u = Lerp(remainder, p1.u, p2.u),
            v = Lerp(remainder, p1.v, p2.v)
        }

        mesh[index]     = centerPoint
        mesh[index + 1] = lerped
        mesh[index + 2] = {
            x = p1.x * radius,
            y = p1.y * radius,
            u = p1.u,
            v = p1.v
        }
    end

    self.radialBarShapeTable = mesh
end

--Creates Radial UI Instance
function RadialProgressBar:New(radius, startingProgressFloat, color) --values between 0 and 1
    local self = setmetatable({}, RadialProgressBar)
    self:BuildUVs(radius, startingProgressFloat)
    self.drawColor = color or defaultColor
    return self
end

function RadialProgressBar:Draw3D2D(drawPos, drawAngle, drawScale)
        cam.Start3D2D(drawPos, drawAngle, drawScale)
            surface.SetDrawColor(self.drawColor)
            surface.SetMaterial(defaultCircleMaterial)
            surface.DrawPoly(self.radialBarShapeTable)
        cam.End3D2D()
end

function RadialProgressBar:ExternalDraw()
        surface.SetDrawColor(self.drawColor)
        surface.SetMaterial(defaultCircleMaterial)
        surface.DrawPoly(self.radialBarShapeTable)
end

return RadialProgressBar
