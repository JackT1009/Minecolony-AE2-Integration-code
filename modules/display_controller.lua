local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_full_refresh = 0
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        -- Hardcoded valid text scale for 4x3 monitor
        monitor.setTextScale(1.0) -- Valid options: 0.5, 1.0, 1.5, 2.0, etc.
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    end
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    
    -- Full refresh handling
    if os.time() - DisplayController.last_full_refresh >= config.REFRESH then
        mon.clear()
        DisplayController.last_full_refresh = os.time()
    end

    -- Header
    mon.setCursorPos(1, 1)
    mon.setTextColor(config.STATUS_COLORS.header)
    mon.write(("Colony Monitor [%ds]"):format(
        config.REFRESH - (os.time() - DisplayController.last_full_refresh)
    ))

    -- Item display
    for i = 1, math.min(#statuses, h-2) do
        local s = statuses[i]
        local line = ("%-15s %3d/%3d"):format(
            s.name:sub(1,15),
            math.min(s.available, s.needed),
            s.needed
        )
        mon.setCursorPos(1, i+2)
        mon.setTextColor(config.STATUS_COLORS[s.status])
        mon.write(line)
    end
end

return DisplayController
