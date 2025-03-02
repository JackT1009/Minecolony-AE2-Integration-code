local config = require("modules.config")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")
local TaskScheduler = require("modules.task_scheduler")
local Colony = require("modules.colony")

-- Initialize systems
local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

-- Main loop
while true do
    local cycle_start = os.epoch("utc")
    local debug_info = {}
    local statuses = {}
    
    -- Phase 1: Get requests
    local requests = Colony.getRequests()
    
    -- Phase 2: Process statuses
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end

    -- Phase 3: Schedule exports
    for _, s in ipairs(statuses) do
        if s.status == "/" then
            TaskScheduler.add({
                fn = function()
                    return pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.WAREHOUSE_DIRECTION)
                end,
                desc = ("Export %dx %s"):format(s.needed, s.name)
            })
        end
    end

    -- Phase 4: Update display
    local elapsed = (os.epoch("utc") - cycle_start) / 1000
    local time_left = math.max(config.REFRESH_INTERVAL - elapsed, 1)
    DisplayController.update(statuses, debug_info, time_left)

    -- Phase 5: Execute tasks
    TaskScheduler.run()

    -- Phase 6: Precise sleep
    local remaining_time = math.max(config.REFRESH_INTERVAL - elapsed, 0.1)
    sleep(remaining_time)
end
