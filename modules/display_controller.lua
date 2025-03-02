local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_update = 0
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
    end
end

function DisplayController.force_refresh(statuses, debug_info, time_left)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    
    -- Full clear
    mon.setBackgroundColor(colors.black)
    mon.clear()
    
    -- Header with live timer
    mon.setTextColor(colors.blue)
    mon.setCursorPos(1, 1)
    mon.write(("ColonyOS | Refresh: %ds "):format(time_left))

    -- Status lines
    local line = 3
    for i = 1, math.min(#statuses, config.MAX_ITEMS_DISPLAY) do
        local s = statuses[i]
        mon.setCursorPos(1, line)
        
        if s.status == "/" then mon.setTextColor(colors.green)
        elseif s.status == "M" then mon.setTextColor(colors.yellow)
        else mon.setTextColor(colors.red) end

        mon.write(("%-15s %s %3d/%3d"):format(
            s.name:sub(1,15),
            s.status,
            s.available,
            s.needed
        ))
        line = line + 1
    end

    -- Debug footer
    mon.setTextColor(colors.lightGray)
    for i = 1, math.min(#debug_info, config.DEBUG_MAX_LINES) do
        mon.setCursorPos(1, h - config.DEBUG_MAX_LINES + i - 1)
        mon.write(debug_info[i]:sub(1,w) or "")
    end
end

return DisplayController
