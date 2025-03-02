-- Main Program
local col = peripheral.find("colonyIntegrator")
local bridge = peripheral.find("meBridge")
local mon = peripheral.find("monitor") or peripheral.wrap("right")

-- Load Modules
local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display")  -- Load LAST

-- Initialize Systems
local inventoryCheck = InventoryChecker.new(bridge)
Display.mon = mon  -- Simple assignment

-- Main Loop
while true do
    local requests = Colony.getRequests()
    local statuses = inventoryCheck:getAllStatuses(requests)
    Display.showStatuses(statuses)
    sleep(5)
end
