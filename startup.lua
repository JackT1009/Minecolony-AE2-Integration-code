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
    local cycle_start = os.time()
    local debug_info = {}
    local requests = Colony.getRequests()
    local statuses = {}
    
    -- Process requests
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end

    -- Schedule exports
    for _, s in ipairs(statuses) do
        if s.status == "/" then
            TaskScheduler.add({
                fn = bridge.exportItem,
                args = {{name = s.name, count = s.needed}, config.WAREHOUSE_DIRECTION}
            })
        end
    end

    -- Update display
    local elapsed = os.time() - cycle_start
    DisplayController.update(
        statuses,
        debug_info,
        math.max(config.REFRESH_INTERVAL - elapsed, 1)
    )

    -- Run scheduled tasks
    TaskScheduler.run()
    sleep(math.max(config.REFRESH_INTERVAL - elapsed, 0.1))
end
