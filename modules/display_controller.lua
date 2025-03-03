local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_full_refresh = 0,
    previous_statuses = {}
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        -- Validate text scale for 4x3 monitor grid
        local w, h = monitor.getSize()
        local scale = math.max(0.5, math.min(1.0, 3/w))  -- Dynamic scaling
        monitor.setTextScale(scale)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    end
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    
    -- Header with fixed valid scale
    mon.setCursorPos(1, 1)
    mon.setTextColor(config.STATUS_COLORS.header)
    mon.write(("Colony Monitor [%ds]"):format(
        config.REFRESH - (os.time() - DisplayController.last_full_refresh)
    ))

    -- Dynamic item display for 4x3 grid
    local items_per_page = h - 2  -- Account for header
    local max_name_length = w - 10  -- Space for "XXX/XXX" counts
    
    for i = 1, math.min(#statuses, items_per_page) do
        local s = statuses[i]
        local line = string.format("%-"..max_name_length.."s %3d/%3d",
            s.name:sub(1, max_name_length),
            math.min(s.available, s.needed),
            s.needed
        )
        
        mon.setCursorPos(1, i+2)
        mon.setTextColor(config.STATUS_COLORS[s.status])
        mon.write(line)
    end
end

return DisplayController
