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

    -- Header with timer
    table.insert(lines, ("Colony Manager [Pg %d] | Refresh: %ds "):format(
        DisplayController.page,
        time_left
    ))

    -- Paginated items
    local start_idx = (DisplayController.page - 1) * config.MAX_ITEMS_DISPLAY + 1
    for i = start_idx, math.min(start_idx + config.MAX_ITEMS_DISPLAY - 1, #statuses) do
        local s = statuses[i]
        table.insert(lines, ("%-18s %s %3d/%3d"):format(
            s.name,
            s.status,
            s.available,
            s.needed
        ))
    end

    -- Debug footer
    for i = 1, config.DEBUG_MAX_LINES do
        table.insert(lines, debug_info[i] or "")
    end

    -- Differential update
    for y, line in ipairs(lines) do
        if line ~= DisplayController.last_lines[y] then
            DisplayController.mon.setCursorPos(1, y)
            DisplayController.mon.clearLine()
            DisplayController.mon.write(line)
        end
    end
    
    DisplayController.last_lines = lines
end

return DisplayController
