local config = require("modules.config")

local DisplayController = {
    last_content = {},
    page = 1
}

function DisplayController.initialize(mon)
    DisplayController.mon = mon
    if not mon then return end
    
    mon.setTextScale(0.5)
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(1,1)
end

function DisplayController.update(statuses, debug_info, time_left)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    
    -- Clear screen properly
    mon.setBackgroundColor(colors.black)
    mon.clear()

    -- Header
    mon.setTextColor(colors.blue)
    mon.setCursorPos(1,1)
    mon.write(("Colony Manager v2.1 | Refresh: %ds "):format(math.floor(time_left)))

    -- Status lines
    local line = 3
    for i = 1, math.min(#statuses, config.MAX_ITEMS_DISPLAY) do
        local s = statuses[i]
        mon.setCursorPos(1, line)
        
        if s.status == "/" then
            mon.setTextColor(colors.green)
        elseif s.status == "M" then
            mon.setTextColor(colors.yellow)
        else
            mon.setTextColor(colors.red)
        end

        mon.write(("%-18s %s %3d/%3d"):format(
            s.name:sub(1,18),
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
        mon.write(debug_info[i]:sub(1,w))
    end
end

return DisplayController
