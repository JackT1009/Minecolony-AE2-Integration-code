local config = require("modules.config")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")
local Colony = require("modules.colony")

-- Initialize
local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

-- Performance timers
local total_cycles = 0
local total_time = 0

-- Main loop
while true do
    local cycle_start = os.epoch("utc")
    local debug_info = {}
    
    -- 1. Get requests
    local requests = Colony.getRequests()
    
    -- 2. Process statuses (batched)
    local statuses = {}
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end

    -- 3. Export logic (non-blocking)
    parallel.waitForAny(function()
        for _, s in ipairs(statuses) do
            if s.status == "/" then
                pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.WAREHOUSE_DIRECTION)
            end
        end
    end)

    -- 4. Update display
    local elapsed = (os.epoch("utc") - cycle_start) / 1000
    local time_left = math.max(config.REFRESH_INTERVAL - elapsed, 1)
    DisplayController.force_refresh(statuses, debug_info, math.floor(time_left))
    
    -- 5. Adaptive sleep
    local sleep_time = math.max(config.REFRESH_INTERVAL - elapsed, 0.1)
    sleep(sleep_time)
    
    -- Performance metrics
    total_cycles = total_cycles + 1
    total_time = total_time + (os.epoch("utc") - cycle_start)
end
