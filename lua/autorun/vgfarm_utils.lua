local NetWriteUInt = net.WriteUInt
local NetReadUInt = net.ReadUInt

VGFarmUtils = {}

--Input only base 2 numbers (2,4,8,16) | Generic Efficieny, Could Use Custom Ranges for known common number ranges which could be more optimal then a generic one
local bitDifference = 2

VGFarmUtils.BitRanges = {}

for i = 1, 32/bitDifference do
    VGFarmUtils.BitRanges[i] = { bits = i * bitDifference, limit = math.pow(2, i * bitDifference)}
end

VGFarmUtils.BitIDs = {}

for key, range in ipairs(VGFarmUtils.BitRanges) do
    VGFarmUtils.BitIDs[range.bits] = key
end

function VGFarmUtils.GetOptimizedBitSize(number)
    for _, range in ipairs(VGFarmUtils.BitRanges) do
        if number < range.limit then
            return range.bits
        end
    end
    error("[VGFarmUtils][GetOptimizedBitSize] "..number.." exceeds 32 bits")
end

VGFarmUtils.BitSizeBitEncoder = VGFarmUtils.GetOptimizedBitSize(#VGFarmUtils.BitRanges)

--Strictly used to write bit info
function VGFarmUtils.SmartNetBitWrite(smartBit)
    NetWriteUInt(VGFarmUtils.BitIDs[smartBit] - 1, VGFarmUtils.BitSizeBitEncoder)
end

--Strictly used to read bit info sent
function VGFarmUtils.SmartNetBitRead()
    return VGFarmUtils.BitRanges[NetReadUInt(VGFarmUtils.BitSizeBitEncoder) + 1].bits
end

-- Check if entity is the base class or direct child of it
function VGFarmUtils.IsDirectChildOrSame(ent, baseClass)
    if not IsValid(ent) then return false end
    local def = scripted_ents.Get(ent:GetClass())
    return def and (ent:GetClass() == baseClass or def.Base == baseClass)
end

local boxColor = Color(255, 0, 0)
function VGFarmUtils.DrawBox(min, max)
    local BottomTopLeft = Vector(min.x, min.y, min.z)
    local BottomTopRight = Vector(max.x, min.y, min.z)
    local BottomBottomLeft = Vector(max.x, min.y, max.z)
    local BottomBottomRight = Vector(min.x, min.y, max.z)

    local TopTopLeft = Vector(min.x, max.y, min.z)
    local TopTopRight = Vector(max.x, max.y, min.z)
    local TopBottomLeft = Vector(max.x, max.y, max.z)
    local TopBottomRight = Vector(min.x, max.y, max.z)

    --Draws Bottom Part
    render.DrawLine(BottomTopLeft, BottomTopRight, boxColor, true)
    render.DrawLine(BottomTopRight, BottomBottomLeft, boxColor, true)
    render.DrawLine(BottomBottomLeft, BottomBottomRight, boxColor, true)
    render.DrawLine(BottomBottomRight, BottomTopLeft, boxColor, true)

    --Draws Top Part
    render.DrawLine(TopTopLeft, TopTopRight, boxColor, true)
    render.DrawLine(TopTopRight, TopBottomLeft, boxColor, true)
    render.DrawLine(TopBottomLeft, TopBottomRight, boxColor, true)
    render.DrawLine(TopBottomRight, TopTopLeft, boxColor, true)

    --Draws Connection between The Parts
    render.DrawLine(BottomTopLeft, TopTopLeft, boxColor, true)
    render.DrawLine(BottomTopRight, TopTopRight, boxColor, true)
    render.DrawLine(BottomBottomLeft, TopBottomLeft, boxColor, true)
    render.DrawLine(BottomBottomRight, TopBottomRight, boxColor, true)
end

function VGFarmUtils.GetNearbyEntityInBox(pos, min, max, className)
    local nearbyEnts = ents.FindInBox(pos + min, pos + max)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == className then
            return ent -- Found at least one
        end
    end
    return nil -- None found
end

function VGFarmUtils.GetNearbyEntityInShpere(pos, radius, className)
    local nearbyEnts = ents.FindInSphere(pos, radius)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == className then
            return ent -- Found at least one
        end
    end

    return nil -- None found
end

function VGFarmUtils.SmartNetUIntWrite(value)
    local smartBit = VGFarmUtils.GetOptimizedBitSize(value)
    VGFarmUtils.SmartNetBitWrite(smartBit, VGFarmUtils.BitSizeBitEncoder)
    NetWriteUInt(value, smartBit)
end

function VGFarmUtils.SmartNetUIntRead()
    local smartBit = VGFarmUtils.SmartNetBitRead(VGFarmUtils.BitSizeBitEncoder)
    return NetReadUInt(smartBit)
end

function VGFarmUtils.SmartNetFloatToIntWrite(value)
    local intValue = value * 10
    local smartBit = VGFarmUtils.GetOptimizedBitSize(intValue)
    VGFarmUtils.SmartNetBitWrite(smartBit, VGFarmUtils.BitSizeBitEncoder)
    NetWriteUInt(intValue, smartBit)
end

function VGFarmUtils.SmartNetFloatToIntRead()
    local smartBit = VGFarmUtils.SmartNetBitRead(VGFarmUtils.BitSizeBitEncoder)
    return NetReadUInt(smartBit) / 10
end

return VGFarmUtils