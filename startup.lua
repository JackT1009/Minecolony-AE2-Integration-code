local config = require("modules.config")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")
local Colony = require("modules.colony")

-- Initialize systems
local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

-- Main tick loop
while true do
    -- 1. Get requests
    local requests = Colony.getRequests()
    
    -- 2. Process statuses
    local statuses = {}
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end
    
    -- 3. Handle exports in parallel
    parallel.waitForAny(
        function()
            for _, s in ipairs(statuses) do
                if s.status == "/" then
                    pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.WAREHOUSE_DIRECTION)
                end
            end
        end,
        function()
            DisplayController.update(statuses)
        end
    )
    
    -- 4. Maintain tick timing
    sleep(0.05)  -- 1 tick
end
