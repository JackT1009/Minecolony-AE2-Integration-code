local config = require("modules.config")

local DisplayController = {
    last_refresh = 0,
    mon = nil
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
    local current_tick = os.time() * 20
    
    -- Update timer every tick
    local ticks_remaining = config.REFRESH_TICKS - (current_tick % config.REFRESH_TICKS)
    local seconds_remaining = math.ceil(ticks_remaining / 20)
    
    -- Full refresh every second (20 ticks)
    if current_tick - DisplayController.last_refresh >= 20 then
        local mon = DisplayController.mon
        mon.clear()
        
        -- Header
        mon.setTextColor(colors.blue)
        mon.setCursorPos(1,1)
        mon.write(("ColonyOS | Refresh: %ds "):format(seconds_remaining))
        
        -- Items
        local line = 3
        for i = 1, math.min(#statuses, config.MAX_ITEMS_DISPLAY) do
            local s = statuses[i]
            mon.setCursorPos(1, line)
            
            if s.status == "/" then mon.setTextColor(colors.green)
            elseif s.status == "M" then mon.setTextColor(colors.yellow)
            else mon.setTextColor(colors.red) end
            
            mon.write(("%-15s %s %3d/%3d"):format(
                s.name:sub(1,15),
                s.status,
                s.available,
                s.needed
            ))
            line = line + 1
        end
        
        DisplayController.last_refresh = current_tick
    end
end

return DisplayController
