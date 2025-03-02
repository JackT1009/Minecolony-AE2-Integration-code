Display = Display or {}

function Display.showStatuses(statuses, debugInfo)
    if not Display.mon then return end
    
    Display.mon.clear()
    local width, height = Display.mon.getSize()
    
    -- Status Header
    Display.mon.setCursorPos(1,1)
    Display.mon.setTextColor(colors.blue)
    Display.mon.write("Colony Inventory Status")
    
    -- Status List (Top 2/3)
    local maxStatusLines = math.floor(height * 0.66) - 2
    local line = 3
    for i, item in ipairs(statuses) do
        if line > maxStatusLines then break end
        
        -- Item name
        Display.mon.setCursorPos(1, line)
        Display.mon.setTextColor(colors.white)
        Display.mon.write(item.name:gsub("minecraft:", ""):sub(1,15))
        
        -- Status text
        local statusColor = colors.red
        if item.status == "/" then statusColor = colors.green
        elseif item.status == "M" then statusColor = colors.yellow
        elseif item.status == "P" then statusColor = colors.orange end
        
        Display.mon.setTextColor(statusColor)
        Display.mon.setCursorPos(18, line)
        Display.mon.write(string.format("%d/%d %s", item.available, item.needed, item.status))
        
        line = line + 1
    end
    
    -- Debug Panel (Bottom 1/3)
    Display.mon.setTextColor(colors.lightGray)
    Display.mon.setCursorPos(1, maxStatusLines + 2)
    Display.mon.write("Debug:")
    
    local debugLine = maxStatusLines + 3
    for i, msg in ipairs(debugInfo or {}) do
        if debugLine >= height then break end
        Display.mon.setCursorPos(1, debugLine)
        Display.mon.write(msg:sub(1, width))
        debugLine = debugLine + 1
    end
end

return Display
