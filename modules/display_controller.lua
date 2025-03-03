-- display_controller.lua
local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_full_refresh = 0,
    previous_statuses = {}
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    end
end

local function same_status(a, b)
    return a and b and a.name == b.name and a.available == b.available and a.needed == b.needed and a.status == b.status
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    
    -- Full refresh handling
    local full_refresh = false
    if os.time() - DisplayController.last_full_refresh >= config.REFRESH_INTERVAL then
        mon.clear()
        DisplayController.last_full_refresh = os.time()
        full_refresh = true
        DisplayController.previous_statuses = {}
    end

    -- Update header
    mon.setCursorPos(1, 1)
    mon.setTextColor(colors.blue)
    mon.write(("Colony Monitor [%02ds]"):format(
        config.REFRESH_INTERVAL - (os.time() - DisplayController.last_full_refresh)
    ))

    -- Update status lines
    local line = 3
    for i = 1, math.min(#statuses, config.MAX_ITEMS_DISPLAY) do
        local s = statuses[i]
        local prev = DisplayController.previous_statuses[i]
        
        if full_refresh or not same_status(prev, s) then
            mon.setCursorPos(1, line)
            mon.setTextColor(config.STATUS_COLORS[s.status])
            mon.write(("%-15s %3d/%3d"):format(
                s.name:sub(1,15),
                math.min(s.available, s.needed),
                s.needed
            ))
            DisplayController.previous_statuses[i] = {
                name = s.name,
                available = s.available,
                needed = s.needed,
                status = s.status
            }
        end
        line = line + 1
    end
end

return DisplayController
