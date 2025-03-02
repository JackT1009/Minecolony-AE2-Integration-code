local Display = {}

function Display.initialize(monitor)
    Display.mon = monitor
    if monitor then 
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
    end
end

function Display.show(statuses, debugInfo)
    if not Display.mon then return end
    
    local w, h = Display.mon.getSize()
    Display.mon.clear()
    
    -- Header
    Display.mon.setCursorPos(1,1)
    Display.mon.setTextColor(colors.blue)
    Display.mon.write("ME Bridge Monitor")
    
    -- Status List
    local line = 3
    for _, item in ipairs(statuses) do
        if line >= h-5 then break end
        
        -- Remove mod prefix for display
        local displayName = item.name:gsub("^[%w_]+:", ""):sub(1, 15)
        
        Display.mon.setCursorPos(1, line)
        Display.mon.setTextColor(colors.white)
        Display.mon.write(displayName)  -- e.g. "tin_ingot"
        
        local color = colors.red
        if item.status == "/" then color = colors.green
        elseif item.status == "M" then color = colors.yellow end
        
        Display.mon.setTextColor(color)
        Display.mon.setCursorPos(17, line)
        Display.mon.write(("%s %d/%d"):format(item.status, item.available, item.needed))
        line = line + 1
    end
    
    -- Debug Info
    Display.mon.setTextColor(colors.lightGray)
    for i, msg in ipairs(debugInfo or {}) do
        Display.mon.setCursorPos(1, h - #debugInfo + i - 1)
        Display.mon.write(msg:sub(1,w))
    end
end

return Display
