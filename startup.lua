-- Main Program
local col = peripheral.find("colonyIntegrator")
local bridge = peripheral.find("meBridge")
local mon = peripheral.find("monitor") or peripheral.wrap("right")

-- Load Modules
local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display") -- Must load LAST

-- Initialize Systems
local inventoryCheck = InventoryChecker.new(bridge)
Display.mon = mon -- Simple assignment

-- Main Loop
while true do
    local requests = Colony.getRequests()
    local statuses = inventoryCheck:getAllStatuses(requests)
    local debugInfo = inventoryCheck:getDebugLog()
    
    Display.showStatuses(statuses, debugInfo)
    
    sleep(5)
end
