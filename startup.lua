local config = require("modules.config")
local Colony = require("modules.colony")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")

-- Initialize peripherals
local bridge = peripheral.find("meBridge") or error("ME Bridge required!")
local monitor = peripheral.find("monitor") or error("Monitor required!")
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

-- Main loop
while true do
    local requests = Colony.getRequests()
    local statuses = {}
    
    -- Get status for each request
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end

    -- Update display
    DisplayController.update(statuses)
    
    -- Handle exports
    for _, s in ipairs(statuses) do
        if s.status == "stocked" then
            pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.WAREHOUSE_DIRECTION)
        end
    end

    sleep(1)  -- Update every second (timer still accurate)
end
