local Display = {}

function Display.initialize(monitor)
    Display.mon = monitor
    if monitor then monitor.setTextScale(0.5) end
end

function Display.show(statuses, debugInfo)
    if not Display.mon then return end
    
    local w, h = Display.mon.getSize()
    Display.mon.clear()
    
    -- Header
    Display.mon.setCursorPos(1,1)
    Display.mon.setTextColor(colors.blue)
    Display.mon.write("Colony Stock System")
    
    -- Statuses
    local line = 3
    for _, item in ipairs(statuses) do
        if line >= h-2 then break end
        
        Display.mon.setCursorPos(1, line)
        Display.mon.setTextColor(colors.white)
        Display.mon.write(item.name:sub(1,15))
        
        local color = colors.red
        if item.status == "/" then color = colors.green
        elseif item.status == "M" then color = colors.yellow end
        
        Display.mon.setTextColor(color)
        Display.mon.setCursorPos(17, line)
        Display.mon.write(("%s %d/%d"):format(item.status, item.available, item.needed))
        line = line + 1
    end
    
    -- Debug Footer
    Display.mon.setTextColor(colors.lightGray)
    for i, msg in ipairs(debugInfo) do
        if (h - #debugInfo + i - 1) >= h then break end
        Display.mon.setCursorPos(1, h - #debugInfo + i - 1)
        Display.mon.write(msg:sub(1,w))
    end
end

return Display
