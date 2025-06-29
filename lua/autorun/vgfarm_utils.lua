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