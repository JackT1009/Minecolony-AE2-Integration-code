local config = require("modules.config")
local Colony = require("modules.colony")
local InventoryManager = require("modules.inventory_manager")
local DisplayController = require("modules.display_controller")

-- Initialize peripherals
local bridge = peripheral.find("meBridge") or error("ME Bridge required!")
local monitor = peripheral.find("monitor") or error("Monitor required!")
local integrator = peripheral.find("colonyIntegrator")

Colony.initialize(integrator)
local inv_mgr = InventoryManager.new(bridge)
DisplayController.initialize(monitor)

local function main_loop()
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
        
        -- Handle exports
        for _, s in ipairs(statuses) do
            if s.status == "stocked" then
                pcall(bridge.exportItem, {name=s.name, count=s.needed}, config.DIRECTION)
            end
        end
        
        os.startTimer(config.REFRESH)
        os.pullEvent("timer")
    end
end

-- Error handling wrapper
local function protected_main()
    while true do
        local success, err = pcall(main_loop)
        if not success then
            print("Error: " .. err)
            print("Restarting in 5 seconds...")
            os.sleep(5)
        end
    end
end

protected_main()
