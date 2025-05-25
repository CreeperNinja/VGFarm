
//Incomplete Do Not Use
local CircleTextureMesh = {}
CircleTextureMesh.__index = CircleTextureMesh

local function isValidBase(n)
    return n >= 8 and bit.band(n, n - 1) == 0
end

//supports only 2 power of 2 segments starting with 8 (8, 16, 32, 64, 128, etc..)
function CircleTextureMesh:New(segments, size, xRatio, yRatio)
    local self = setmetatable({}, CircleTextureMesh)
    if not isValidBase(segments) then
        print("Warning! number of segments is not supported yet! please use numbers like 8 16 32 64 128")
    end
    self.points = {}
    self.segments = segments
    self.radianSteps = math.pi * 2 / segments
    self:CreatePoints(size, xRatio, yRatio)
    return self
end

function CircleTextureMesh:UpdateSegments(segments, size, xRatio, yRatio)
    self.segments = segments
    self.radianSteps = math.pi * 2 / self.segments
    CreatePoints(size, xRatio, yRatio)
end

//Creates a UV map of the sprite with tables 1 indexed based table - assuming there is no spacing between the border and frame (only spacing between frames) - deprecated
function CircleTextureMesh:CreatePoints(size, xRatio, yRatio)
    self.points = {}
    print("Point: 0     x: 0    y: 0    u: 0.5  v: 0.5")
    table.insert(self.points, {x = 0, y = 0, u = 0.5, v = 0.5})
    for i = 0, self.segments - 1 do
        -- For each angle
        local radian = i * self.radianSteps
        local xPos = math.sin(radian) * xRatio
        local yPos = math.cos(radian) * yRatio

        local uPos = 1 - (0.5 + xPos * 0.5)
        local vPos = 0.5 - yPos * 0.5
        print("Point: "..i + 1 .."   x: "..xPos.."  y: "..yPos.."  u: "..uPos.."  v:"..vPos)
        table.insert(self.points, {x = xPos, y = yPos, u = uPos, v = vPos})
    end
    print("Points Created")
end

//Creates A Radial Mesh
function CircleTextureMesh:CreateMesh(value, valueMax)
    
    print("Mesh Check 1")
    local textureMesh = {}

    //Inernal Values - Do Not Change
    local maxTriangleRadianAngle =  math.rad(45)
    local circleRadian = math.pi * 2
    local maxTotalClamp = circleRadian / maxTriangleRadianAngle

    local progress = math.Clamp(value / valueMax, 0, 1)
    local lastSegment = math.ceil(self.segments * progress) //Rounds Up to the nearest segment
    local lastSegmentRadianAngle = circleRadian * lastSegment / self.segments

    print("Debbug:\r\n  maxTriangleRadianAngle: "..maxTriangleRadianAngle..
    "\r\n   progress: "..progress..
    "\r\n   lastSegment: "..lastSegment..
    "\r\n   lastSegmentRadianAngle: "..lastSegmentRadianAngle..
    "\r\n   maxTotalClamp "..maxTotalClamp
    )
    
    //Triangle Clamping
    local clampCount = math.floor(lastSegmentRadianAngle / maxTriangleRadianAngle) //Counts how many times to clamp triangles
    local leftover = lastSegmentRadianAngle - (clampCount * maxTriangleRadianAngle)
    local clampIndex = math.floor(self.segments / (circleRadian / maxTriangleRadianAngle))
    print("Clamp Count: "..clampCount.."    leftover: "..leftover.."    clampIndex: "..clampIndex.." = "..self.segments.." / "..circleRadian.." / "..maxTriangleRadianAngle)

    print("Mesh Check 2")
    for i = 0, clampCount - 1 do
        local index = i * clampIndex + 1
        local lastIndex = clampIndex + index
        if lastIndex > self.segments then lastIndex = 1 end
        table.insert(textureMesh, self.points[1])
        table.insert(textureMesh, self.points[index])
        table.insert(textureMesh, self.points[lastIndex])
        print("Clamp Triangle "..i + 1 .." = 0 -> "..index.." -> "..lastIndex)
    end
    
    print("Mesh Check 3")
    if leftover > 0 then
        table.insert(textureMesh, self.points[1])
        table.insert(textureMesh, self.points[clampIndex * clampCount + 1])
        table.insert(textureMesh, self.points[lastSegment])
        print("End Triangle "..clampCount + 1 .."    Left Over Radians: "..leftover.." = 0 -> "..clampIndex * clampCount + 1 .." -> "..lastSegment) 
    end

    print("Mesh Created! verticies: "..#textureMesh)
    return textureMesh
end

return CircleTextureMesh
