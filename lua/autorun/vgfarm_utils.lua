-- lua/autorun/entity_utils.lua
VGFarmUtils = {}

-- Check if entity is the base class or direct child of it
function VGFarmUtils.IsDirectChildOrSame(ent, baseClass)
    if not IsValid(ent) then return false end
    local def = scripted_ents.Get(ent:GetClass())
    return def and (ent:GetClass() == baseClass or def.Base == baseClass)
end
