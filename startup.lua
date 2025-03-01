-- Main Program
local col = peripheral.find("colonyIntegrator")
local bridge = peripheral.find("meBridge")
local mon = peripheral.find("monitor") or peripheral.wrap("right")

-- Load Modules
local Colony = require("modules/colony")
local Display = require("modules/display")
local InventoryChecker = require("modules/inventory_checker")

-- Initialize Systems
local inventoryCheck = InventoryChecker.new(bridge)
Display.initialize(mon)

-- Main Loop
while true do
    local requests = Colony.getRequests()
    local statuses = inventoryCheck:getAllStatuses(requests)
    
    Display.showStatuses(statuses)
    
    sleep(5)
end
