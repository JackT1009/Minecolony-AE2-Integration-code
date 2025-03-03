local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_full_refresh = 0
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    end
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    
    -- Full refresh every 5 seconds
    if os.time() - DisplayController.last_full_refresh >= config.REFRESH_INTERVAL then
        mon.clear()
        DisplayController.last_full_refresh = os.time()
    end

    -- Header with countdown
    mon.setCursorPos(1,1)
    mon.setTextColor(colors.blue)
    mon.write(("Colony Monitor [%ds]"):format(
        config.REFRESH_INTERVAL - (os.time() - DisplayController.last_full_refresh)
    ))

    -- Status lines
    local line = 3
    for i = 1, math.min(#statuses, config.MAX_ITEMS_DISPLAY) do
        local s = statuses[i]
        mon.setCursorPos(1, line)
        mon.setTextColor(config.STATUS_COLORS[s.status])
        mon.write(("%-15s %3d/%3d"):format(
            s.name:sub(1,15),
            math.min(s.available, s.needed),
            s.needed
        ))
        line = line + 1
    end
end

return DisplayController
