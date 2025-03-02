local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_refresh = 0
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        monitor.setCursorPos(1,1)
        monitor.setTextColor(colors.white)
        monitor.write("Display Initialized")
        sleep(1)
    end
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    
    -- Always clear and redraw
    DisplayController.mon.clear()
    
    -- Header
    DisplayController.mon.setCursorPos(1,1)
    DisplayController.mon.setTextColor(colors.blue)
    DisplayController.mon.write("ColonyOS - Working")

    -- Items
    for i = 1, math.min(#statuses, config.MAX_ITEMS_DISPLAY) do
        DisplayController.mon.setCursorPos(1, i+2)
        local s = statuses[i]
        if s then
            DisplayController.mon.setTextColor(colors.white)
            DisplayController.mon.write(("%s: %d/%d"):format(s.name, s.available, s.needed))
        end
    end
end

return DisplayController
