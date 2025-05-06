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

-- 💻 Monospace Font (great for numbers or aligned values)
surface.CreateFont("GraphMono", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true
})

local weekDays = 
{
    "Today"
}

local PANEL = {}

function PANEL:Init()
    self:SetSize(100, 40)

    // Text
    self.customText = "Market Graph Title"
    
    // Data
    self.marketData = {}

    // Settings
    self.paddingLeft = 75
    self.paddingBottom = 50
    self.paddingTop = 75
    self.paddingRight = 50
    self.dotSize = 5
    //add or remove for this option
    self.gridEnabled = true 

    //Offsets for texts - specifically in grid text and index
    self.xOffset = 30
    self.yOffset = 0

    // Colors
    self.backgroundColor = Color(82, 82, 82, 255)
    self.axiesColor =      Color(255, 255, 255, 255)
    self.axiesBackgroundColor =      Color(164, 164, 164, 255)
    self.customTextColor = Color(255, 255, 255, 255)
    self.axiesYTextColor = Color(255, 255, 255, 255)
    self.axiesXTextColor = Color(255, 255, 255, 255)
end

function PANEL:Paint(w, h)  

    // Internal Data
    //Starting Point Of The Graph (From Bottom Left)
    local xAxies = self.paddingLeft
    local yAxies = h - self.paddingBottom
    
    //Area of drawn graph
    local graphAreaX = w - self.paddingLeft - self.paddingRight
    local graphAreaY = h - self.paddingBottom - self.paddingTop

    local maxData = math.max(unpack(self.marketData))

    //Recommended to not change unless using different font sizes
    local constYOffset = 10
    local constXOffset = 10

    -- Background
    surface.SetDrawColor(82, 82, 82, 82)
    surface.DrawRect(0, 0, w, h)

    local scaledXOffset = self.xOffset / (w / graphAreaX)

    // Title Text
    draw.SimpleText(self.customText, "GraphTitle", w * 0.5, self.paddingTop/1.5, self.customTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    -- Y Axis labels (e.g., 0%, 10%, ..., max)
    local segments = 9
    for i = 0, segments do
        local value = math.floor(i / (segments) * maxData)
        local y = yAxies - (i) / (segments) * graphAreaY
        draw.SimpleText("$"..value, "GraphAxies", self.paddingLeft * 0.75, y - constYOffset, Color(255,255,255,180), TEXT_ALIGN_RIGHT)

        // Background Axies
        surface.SetDrawColor(self.axiesBackgroundColor)
        surface.DrawLine(xAxies, y, w, y)

        // Label Lines
        surface.SetDrawColor(self.axiesColor)
        surface.DrawLine(xAxies, y, xAxies - 10, y)
    end

    //fill grid with vertical lines
    for i = 1, w / graphAreaX * #self.marketData do
        local x = xAxies + scaledXOffset + (graphAreaX / #self.marketData) * (i - 1) + self.dotSize/2

        // Background Axies
        surface.SetDrawColor(self.axiesBackgroundColor)
        surface.DrawLine(x, yAxies, x, self.paddingTop)
        

    end

    local y = yAxies - (self.marketData[1] / maxData) * graphAreaY
    local nextX = xAxies + scaledXOffset
    local nextY = yAxies - (self.marketData[2] / maxData) * graphAreaY
    
    surface.SetDrawColor(100, 200, 255, 255)
    surface.DrawLine(xAxies, y - self.dotSize/4, nextX , nextY - self.dotSize/4)

    -- Draw points and thier values
    for i = 2, #self.marketData do
        local x = xAxies + scaledXOffset + (graphAreaX / #self.marketData) * (i - 2)
        local y = yAxies - (self.marketData[i] / maxData) * graphAreaY

        -- Draw data point
        surface.DrawRect(x, y - self.dotSize/2, self.dotSize, self.dotSize)

        -- Draw line to next point
        if i < #self.marketData then
            local nextX = xAxies + scaledXOffset + (graphAreaX / #self.marketData) * (i-1)
            local nextY = yAxies - (self.marketData[i+1] / maxData) * graphAreaY
            surface.DrawLine(x + self.dotSize/2, y - self.dotSize/4, nextX + self.dotSize/2, nextY - self.dotSize/4)
        end

        -- Label data point
        draw.SimpleText("$"..self.marketData[i], "GraphMono", x, y - constYOffset, Color(255, 255, 0, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText("Days Ago", "GraphAxies", xAxies + constXOffset, yAxies + constYOffset, Color(255, 255, 255, 180), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

    -- X axis labels (optional: e.g., time or index)
    for i = 2, #self.marketData do
        local x = xAxies + scaledXOffset + (graphAreaX / #self.marketData) * (i - 2) + self.dotSize/2

        draw.SimpleText(weekDays[#self.marketData - i + 1] or (#self.marketData - i), "GraphAxies", x, yAxies + constYOffset, Color(255, 255, 255, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local x = xAxies + scaledXOffset + graphAreaX+ self.dotSize/2

    -- Axies
    surface.SetDrawColor(self.axiesColor)
    surface.DrawLine(xAxies, yAxies, w , yAxies) -- X axis
    surface.DrawLine(xAxies, yAxies , xAxies, yAxies - graphAreaY)   -- Y axis

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
end

vgui.Register("MGraph", PANEL, "DPanel")
