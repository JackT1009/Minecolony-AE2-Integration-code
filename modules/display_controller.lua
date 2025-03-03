local config = require("modules.config")

local DisplayController = {
    mon = nil,
    last_full_refresh = 0,
    previous_statuses = {}
}

function DisplayController.initialize(monitor)
    DisplayController.mon = monitor
    if monitor then
        monitor.setTextScale(0.4)  -- Smaller scale for more text
        monitor.setBackgroundColor(colors.black)
        monitor.clear()
    end
end

local function calculate_layout()
    local mon = DisplayController.mon
    local w, h = mon.getSize()
    return {
        name_width = math.floor(w * 0.6),
        count_width = math.floor(w * 0.4) - 3
    }
end

function DisplayController.update(statuses)
    if not DisplayController.mon then return end
    local mon = DisplayController.mon
    local layout = calculate_layout()
    
    -- Full refresh handling
    if os.time() - DisplayController.last_full_refresh >= config.REFRESH then
        mon.clear()
        DisplayController.last_full_refresh = os.time()
        DisplayController.previous_statuses = {}
    end

    -- Header with dynamic sizing
    mon.setCursorPos(1, 1)
    mon.setTextColor(config.STATUS_COLORS.header)
    mon.write(("Colony Monitor [%ds]"):format(
        config.REFRESH - (os.time() - DisplayController.last_full_refresh)
    ))

    -- Status lines with dynamic formatting
    local line = 3
    for i, s in ipairs(statuses) do
        local fmt = string.format("%%-%ds %%3d/%%3d", layout.name_width)
        local text = fmt:format(
            s.name:sub(1, layout.name_width),
            math.min(s.available, s.needed),
            s.needed
        )
        
        if text ~= DisplayController.previous_statuses[i] then
            mon.setCursorPos(1, line)
            mon.setTextColor(config.STATUS_COLORS[s.status])
            mon.write(text)
            DisplayController.previous_statuses[i] = text
        end
        line = line + 1
    end
end

return DisplayController
