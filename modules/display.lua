local Display = {}

function Display.initialize(monitor)
    Display.mon = monitor
    if monitor then 
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
    end
end

function Display.show(statuses, debugInfo, timeLeft)
    if not Display.mon then return end
    
    local w, h = Display.mon.getSize()
    Display.mon.clear()
    
    -- Header with timer
    Display.mon.setCursorPos(1,1)
    Display.mon.setTextColor(colors.blue)
    Display.mon.write(("ME Monitor | Refresh in: %ds "):format(timeLeft))
    
    -- Status List (Longer names)
    local line = 3
    for _, item in ipairs(statuses) do
        if line >= h-5 then break end
        
        -- Display name (20 chars max)
        local displayName = item.name:gsub("^[%w_]+:", ""):sub(1, 20)
        
        Display.mon.setCursorPos(1, line)
        Display.mon.setTextColor(colors.white)
        Display.mon.write(displayName)
        
        -- Status + Sent indicator
        local statusText
        local color = colors.red
        if item.status == "/" then
            color = colors.green
            statusText = ("/ %d/%d"):format(item.available, item.needed)
            if item.sent then statusText = statusText .. " (Sent)" end
        elseif item.status == "M" then
            color = colors.yellow
            statusText = ("M %d/%d"):format(item.available, item.needed)
        else
            statusText = ("P %d/%d"):format(item.available, item.needed)
        end
        
        Display.mon.setTextColor(color)
        Display.mon.setCursorPos(22, line)  -- Adjusted for longer names
        Display.mon.write(statusText)
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
