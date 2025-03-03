-- startup.lua
local config = require("modules.config")
local Colony = require("modules.colony")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")
local TaskScheduler = require("modules.task_scheduler")

-- Initialize peripherals
local bridge = peripheral.find("meBridge") or error("ME Bridge required!")
local monitor = peripheral.find("monitor") or error("Monitor required!")
local integrator = peripheral.find("colonyIntegrator")

Colony.initialize(integrator)
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

-- Main loop
while true do
    inv_mgr:refresh()
    local requests = Colony.getRequests()
    local statuses = {}
    
    -- Process requests
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end

    -- Update display
    DisplayController.update(statuses)
    
    -- Schedule exports
    for _, s in ipairs(statuses) do
        if s.status == "stocked" then
            TaskScheduler.add({
                fn = function()
                    pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.WAREHOUSE_DIRECTION)
                end,
                args = {}
            })
        end
    end
    
    TaskScheduler.run()
    sleep(1)
end
