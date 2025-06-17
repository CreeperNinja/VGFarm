-- modules/spritesheet.lua
local SpriteSheet = {}
SpriteSheet.__index = SpriteSheet

function SpriteSheet:New(materialPath, frameSize, spacing, framesPerRow, totalFrames)
    local self = setmetatable({}, SpriteSheet)
    self.spriteMaterial = Material(materialPath)
    self.frameSize = frameSize
    self.spacing = spacing
    self.framesPerRow = framesPerRow
    self.totalFrames = totalFrames
    self.uvs = {}

    self:BuildUVs()
    return self
end

function SpriteSheet:NewHorizontal(materialPath, totalFrames)
    if(self.spriteMaterial:Width() == 4096) then
        print("Size and Spacing Might Not Work WIth This Image Size")
    end
    
    local self = setmetatable({}, SpriteSheet)
    self.spriteMaterial = Material(materialPath)
    self.frameSize = self.spriteMaterial:Width() / totalFrames
    self.spacing = spacing
    self.totalFrames = totalFrames
    self.uvs = {}

    print("Frame Size: "..self.frameSize)
    print("Building UV's")
    self:BuildHorizontalUVs()
    
    print("UV's Finished Building")
    return self
end

//Creates a UV map of the sprite with tables 1 indexed based table - assuming there is no spacing between the border and frame (only spacing between frames) - deprecated
function SpriteSheet:BuildUVs()

    //Not Fully Implemented - Do Not Use
    local frame = self.frameSize + self.spacing

    for i = 0, self.totalFrames - 1 do
        local row = math.floor(i / self.framesPerRow)
        local col = i % self.framesPerRow

        local x = col * frame
        local y = row * frame

        self.uvs[i+1] = {x, y}
    end
end

//Creates an horizontal only UV map of the sprite with tables 1 indexed based table - assuming there is spacing from borders
function SpriteSheet:BuildHorizontalUVs()

    -- local frame = self.frameSizeNormalized + self.spacingWidthNormalized
    -- for i = 0, self.totalFrames - 1 do

    --     local x = i * frame / self.spriteMaterial:Width() 
    --     self.uvs[i+1] = {x, self.spacingNormalized}
    --     print(x)
    -- end
end

function SpriteSheet:GetUV(index)
    return unpack(self.uvs[math.Clamp(index, 1, self.totalFrames)])
end

function SpriteSheet:DrawFrame(index, x, y, w, h, color)
    local spriteMaterial = self.spriteMaterial
    surface.SetMaterial(spriteMaterial)
    surface.SetDrawColor(color or color_white)

    local xUV, yUV= self:GetUV(index)
    print("Drawing Frame: "..index.." | xUV: "..xUV.."  yUV: "..yUV.."  xUVWidth: "..xUV + self.frameSizeNormalized.."  yUVHeight: "..self.frameBottomNormalized.."\r\nx: "..x.."    y: "..y.."  width: "..w.."  height: "..h)
    surface.DrawTexturedRectUV(x, y, w, h, xUV, yUV, xUV + self.frameSizeNormalized, self.frameBottomNormalized)
end

return SpriteSheet
