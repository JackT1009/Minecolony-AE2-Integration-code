-- modules/display.lua
Display = Display or {}

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
        
        -- Status and counts
        local statusText
        if item.status == "/" then
            Display.mon.setTextColor(colors.green)
            statusText = string.format("%d/%d %s", item.available, item.needed, item.status)
        elseif item.status == "P" then
            Display.mon.setTextColor(colors.yellow)
            statusText = string.format("%d/%d %s", item.available, item.needed, item.status)
        else
            Display.mon.setTextColor(colors.red)
            statusText = string.format("%d/%d %s", item.available, item.needed, item.status)
        end
        
        Display.mon.setCursorPos(18, line)
        Display.mon.write(statusText)
        line = line + 1
    end
    
    -- Legend
    Display.mon.setTextColor(colors.white)
    Display.mon.setCursorPos(1, Display.mon.getSize())
    Display.mon.write("Avail/Need | /=Stocked | P=Pattern | X=Error")
end

return Display  -- Critical line
