local config = require("modules.config")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")
local Colony = require("modules.colony")

-- Verify peripherals
local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")

if not bridge then
    error("ME Bridge not found! Place it adjacent to an ME Interface.")
end

if not monitor then
    error("Monitor not found! Attach a monitor to the computer.")
end

-- Initialize systems
print("Initializing...")
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

-- First forced refresh
DisplayController.mon.clear()
DisplayController.mon.setCursorPos(1,1)
DisplayController.mon.write("Booting ColonyOS...")

-- Main loop
while true do
    -- Get requests
    local requests = Colony.getRequests()
    print("Found "..#requests.." requests")
    
    -- Process statuses
    local statuses = {}
    for _, req in ipairs(requests) do
        table.insert(statuses, inv_mgr:get_status(req.name, req.count))
    end

    -- Update display
    DisplayController.update(statuses)
    
    -- Basic exports
    for _, s in ipairs(statuses) do
        if s.status == "/" then
            pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.WAREHOUSE_DIRECTION)
        end
    end

    sleep(0.05)  -- 1 tick
end
