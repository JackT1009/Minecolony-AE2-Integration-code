local Display = {}
Display.__index = Display

function Display.initialize(monitor)
    Display.mon = monitor
    if Display.mon then
        Display.mon.setTextScale(0.5)
        Display.mon.setBackgroundColor(colors.black)
    end
end

function Display.showStatuses(statuses)
    if not Display.mon then return end
    
    Display.mon.clear()
    Display.mon.setCursorPos(1,1)
    Display.mon.setTextColor(colors.blue)
    Display.mon.write("Colony Inventory Status")
    
    local line = 3
    for _, item in ipairs(statuses) do
        Display.mon.setCursorPos(1, line)
        Display.mon.setTextColor(colors.white)
        Display.mon.write(item.name:gsub("minecraft:", ""):sub(1,15))
        
        Display.mon.setCursorPos(18, line)
        if item.status == "/" then
            Display.mon.setTextColor(colors.green)
        elseif item.status == "P" then
            Display.mon.setTextColor(colors.yellow)
        else
            Display.mon.setTextColor(colors.red)
        end
        Display.mon.write(item.status.." x"..item.count)
        
        line = line + 1
    end
    
    -- Legend
    Display.mon.setTextColor(colors.white)
    Display.mon.setCursorPos(1, Display.mon.getSize())
    Display.mon.write("/=Stocked | P=Need Pattern | X=Error")
end

return Display
