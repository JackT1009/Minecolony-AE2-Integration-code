local config = require("modules.config")

local DisplayController = {
    last_lines = {},
    page = 1
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    end
end

function DisplayController.update(statuses, debug_info, time_left)
    if not DisplayController.mon then return end
    
    local w, h = DisplayController.mon.getSize()
    local lines = {}

    -- Header with timer (blue)
    DisplayController.mon.setTextColor(colors.blue)
    DisplayController.mon.setCursorPos(1, 1)
    DisplayController.mon.write(("Colony Manager [Pg %d] | Refresh: %ds "):format(
        DisplayController.page,
        math.floor(time_left)
    ))

    -- Status items (color-coded)
    local line_num = 3
    local start_idx = (DisplayController.page - 1) * config.MAX_ITEMS_DISPLAY + 1
    for i = start_idx, math.min(start_idx + config.MAX_ITEMS_DISPLAY - 1, #statuses) do
        local s = statuses[i]
        local color = colors.white
        if s.status == "/" then color = colors.green
        elseif s.status == "M" then color = colors.yellow
        else color = colors.red end

        DisplayController.mon.setTextColor(color)
        DisplayController.mon.setCursorPos(1, line_num)
        DisplayController.mon.write(("%-18s %s %3d/%3d"):format(
            s.name,
            s.status,
            s.available,
            s.needed
        ))
        line_num = line_num + 1
    end

    -- Debug footer (white)
    DisplayController.mon.setTextColor(colors.white)
    for i = 1, config.DEBUG_MAX_LINES do
        DisplayController.mon.setCursorPos(1, h - config.DEBUG_MAX_LINES + i - 1)
        DisplayController.mon.write(debug_info[i] or "")
    end
end

return DisplayController
