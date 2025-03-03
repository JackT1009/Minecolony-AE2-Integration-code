local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_full_refresh = 0,
    previous_statuses = {}
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        -- Use minimum valid text scale (0.5) with optimized layout
        monitor.setTextScale(0.5)
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
        monitor.setCursorBlink(false)
    end
end

local function calculate_layout()
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    return {
        name_col = 1,  -- Start at first column
        count_col = w - 9,  -- Reserve 9 characters for "XXX/XXX"
        max_lines = h - 2  -- Account for header space
    }
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local layout = calculate_layout()
    local w, h = mon.getSize()
    
    -- Full refresh handling
    if os.time() - DisplayController.last_full_refresh >= config.REFRESH then
        mon.clear()
        DisplayController.last_full_refresh = os.time()
        DisplayController.previous_statuses = {}
    end

    -- Header with dynamic countdown
    mon.setCursorPos(1, 1)
    mon.setTextColor(config.STATUS_COLORS.header)
    mon.write(("Colony Monitor [%ds]"):format(
        config.REFRESH - (os.time() - DisplayController.last_full_refresh)
    ))

    -- Status lines with two-column layout
    local line = 3
    for i = 1, math.min(#statuses, layout.max_lines) do
        local s = statuses[i]
        local display_text = string.format("%s: %d/%d", 
            s.name:sub(1, layout.count_col - layout.name_col - 3),
            math.min(s.available, s.needed),
            s.needed
        )
        
        if display_text ~= DisplayController.previous_statuses[i] then
            mon.setCursorPos(layout.name_col, line)
            mon.setTextColor(config.STATUS_COLORS[s.status])
            mon.write(display_text)
            DisplayController.previous_statuses[i] = display_text
        end
        
        line = line + 1
    end
end

return DisplayController
