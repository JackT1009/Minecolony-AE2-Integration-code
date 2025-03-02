local config = require("config")
local DisplayController = {
    last_lines = {},
    page = 1
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    monitor.setTextScale(0.5)
    monitor.setBackgroundColor(colors.black)
end

function DisplayController.update(statuses, debug_info, time_left)
    if not DisplayController.mon then return end
    
    local w, h = DisplayController.mon.getSize()
    local lines = {}

    -- Header
    table.insert(lines, ("Minecolony AE2 [%d/%d] | Refresh: %d "):format(
        DisplayController.page,
        math.ceil(#statuses / config.MAX_ITEMS_DISPLAY),
        time_left
    ))

    -- Paginated items
    local start_idx = (DisplayController.page - 1) * config.MAX_ITEMS_DISPLAY + 1
    for i = start_idx, math.min(start_idx + config.MAX_ITEMS_DISPLAY - 1, #statuses) do
        local s = statuses[i]
        table.insert(lines, ("%-15s %s %3d/%3d"):format(
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
            DisplayController.mon.blit(line, string.rep("f", #line), string.rep("0", #line))
        end
    end
    
    DisplayController.last_lines = lines
end
