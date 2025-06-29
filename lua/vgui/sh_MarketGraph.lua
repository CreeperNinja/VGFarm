-- 🅰️ Large Title Font
surface.CreateFont("GraphTitle", {
    font = "Roboto",
    size = 32,
    weight = 700,
    antialias = true
})

-- 🅱️ Subtitle / Label Font
surface.CreateFont("GraphAxies", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

-- 💻 Monospace Font
surface.CreateFont("GraphMono", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

//Localized Functions
local max = math.max
local floor = math.floor
local unpack = unpack
local Color = Color
local SetDrawColor = surface.SetDrawColor
local DrawLine = surface.DrawLine
local DrawRect = surface.DrawRect
local DrawSimpleText = draw.SimpleText
local DrawRoundedBox = draw.RoundedBox

local TEXT_ALIGN_TOP    = TEXT_ALIGN_TOP   
local TEXT_ALIGN_BOTTOM = TEXT_ALIGN_BOTTOM
local TEXT_ALIGN_LEFT   = TEXT_ALIGN_LEFT  
local TEXT_ALIGN_RIGHT  = TEXT_ALIGN_RIGHT 
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

local weekDays = 
{
    "Today"
}

local PANEL = {}
local Color_White = Color(255, 255, 255, 255)

function PANEL:Init()
    self:SetSize(100, 40)

    // Text
    self.customText = "Market Graph Title"
    
    // Data
    self.marketData = {}
    self.maxData = nil 
    self.minMarketValue = 0
    self.maxMarketValue = nil 
    self.marketDataCount = #self.marketData

    // Settings
    self.paddingLeft = 75
    self.paddingBottom = 50
    self.paddingTop = 75
    self.paddingRight = -25
    self.dotSize = 6

    self.ySegments = 10

    //add or remove for this option
    self.gridEnabled = true 

    //Offsets for texts - specifically in grid text and index
    self.xOffset = 30
    self.yOffset = 0

    // Colors
    self.backgroundColor = Color(80, 80, 80, 255)
    self.axiesColor =      Color(255, 255, 255)
    self.axiesBackgroundColor =      Color(100, 100, 100, 255)
    self.customTextColor = Color(255, 255, 255, 255)
    self.axiesYTextColor = Color(255, 255, 255)
    self.axiesXTextColor = Color(255, 255, 255)
    self.valueColor = Color(0, 255, 0, 255)
    self.valueDotColor = Color(100, 200, 255, 255) // or Color(100, 200, 255, 255)
    self.valueLineColor = Color(200, 200, 200, 255)

    -- Internal Data

    self.xPadding = self.paddingLeft + self.paddingRight
    self.yPadding = self.paddingBottom + self.paddingTop

    //Recommended to not change unless using a different font size
    self.constYOffset = 10
    self.constXOffset = 10

end

function PANEL:Paint(w, h)  

    // Internal Data

    //Starting Point Of The Graph (From Bottom Left)
    local xAxies = self.paddingLeft
    local yAxies = h - self.paddingBottom
    
    //Area of drawn graph
    local graphAreaX = w - self.xPadding
    local graphAreaY = h - self.yPadding

    -- Background
    SetDrawColor(self.backgroundColor)
    DrawRect(0, 0, w, h)

    local scaledXOffset = self.xOffset / (w / graphAreaX)

    // Title Text
    DrawSimpleText(self.customText, "GraphTitle", w * 0.5, self.paddingTop/1.5, self.customTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    -- Y Axis labels (e.g., 0%, 10%, ..., max)
    for i = 0, self.ySegments do
        local value = floor(i / (self.ySegments) * self.maxData * 10) / 10
        local y = yAxies - (i) / (self.ySegments) * graphAreaY
        DrawSimpleText("$"..value, "GraphAxies", self.paddingLeft * 0.75, y - self.constYOffset, self.axiesYTextColor, TEXT_ALIGN_RIGHT)

        // Background Axies
        SetDrawColor(self.axiesBackgroundColor)
        DrawLine(xAxies, y, w, y)

        // Label Lines
        SetDrawColor(self.axiesColor)
        DrawLine(xAxies, y, xAxies - 10, y)
    end

    //fill grid with vertical lines
    for i = 1, w / graphAreaX * self.marketDataCount do
        local x = xAxies + scaledXOffset + (graphAreaX / self.marketDataCount) * (i - 1) + self.dotSize/2

        // Background Axies
        SetDrawColor(self.axiesBackgroundColor)
        DrawLine(x, yAxies, x, self.paddingTop)
    end

    //Draw X axies info
    local y = yAxies - (self.marketData[1] / self.maxData) * graphAreaY
    local nextX = xAxies + scaledXOffset
    local nextY = yAxies - (self.marketData[2] / self.maxData) * graphAreaY
    
    -- Axies
    SetDrawColor(self.axiesColor)
    DrawLine(xAxies, yAxies, w , yAxies) -- X axis
    DrawLine(xAxies, yAxies , xAxies, yAxies - graphAreaY)   -- Y axis
    
    SetDrawColor(self.valueLineColor)
    DrawLine(xAxies, y - self.dotSize/4, nextX , nextY - self.dotSize/4)

    -- Draw points and thier values
    for i = 2, self.marketDataCount do
        local x = xAxies + scaledXOffset + (graphAreaX / self.marketDataCount) * (i - 2)
        local y = yAxies - (self.marketData[i] / self.maxData) * graphAreaY

        -- Draw line to next point
        SetDrawColor(self.valueLineColor)
        if i < self.marketDataCount then
            local nextX = xAxies + scaledXOffset + (graphAreaX / self.marketDataCount) * (i-1)
            local nextY = yAxies - (self.marketData[i+1] / self.maxData) * graphAreaY
            DrawLine(x + self.dotSize/2, y - self.dotSize/4, nextX + self.dotSize/2, nextY - self.dotSize/4)
        end
        
        -- Draw data point
        DrawRoundedBox(45, x, y - self.dotSize/2, self.dotSize, self.dotSize, self.valueDotColor)

        -- Label data point
        DrawSimpleText("$"..self.marketData[i], "GraphMono", x, y - self.constYOffset, self.valueColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    DrawSimpleText("Days Ago", "GraphAxies", xAxies + self.constXOffset, yAxies + self.constYOffset, self.axiesXTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    -- X axis labels (optional: e.g., time or index)
    for i = 2, self.marketDataCount do
        local x = xAxies + scaledXOffset + (graphAreaX / self.marketDataCount) * (i - 2) + self.dotSize/2

        DrawSimpleText(weekDays[self.marketDataCount - i + 1] or (self.marketDataCount - i), "GraphAxies", x, yAxies + self.constYOffset, self.axiesXTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local x = xAxies + scaledXOffset + graphAreaX+ self.dotSize/2


end

function PANEL:SetCustomText(text)
    self.customText = text
end

//Removes The Left Most Value And puts a new one at the Right most side
function PANEL:ReplaceOldValue(value)
    //if !IsValid(value) then print("Replacing Value Faild! | invalid value: "..value) return end
    table.remove(self.marketData, 1)
    table.insert(self.marketData, value )
end

function PANEL:SetMarketData(dataTable)
    self.marketData = dataTable
    self.marketDataCount = #self.marketData

    self:SetMaxMarketValue(self.maxMarketValue)
end

function PANEL:SetMaxMarketValue(maxNum)
    self.maxMarketValue = maxNum
    --Switches Y Axis Value Modes: Free Market Range / Set Market Range
    if self.maxMarketValue == nil or self.maxMarketValue == 0 then
        self.maxData = max(unpack(self.marketData))
    else
        self.maxData = self.maxMarketValue
    end

end

vgui.Register("MGraph", PANEL, "DPanel")
