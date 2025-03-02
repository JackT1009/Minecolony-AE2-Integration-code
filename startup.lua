local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")

local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display")

Display.initialize(monitor)
local checker = InventoryChecker.new(bridge)

while true do
    local requests = Colony.getRequests()
    local statuses, debugInfo = checker:getAllStatuses(requests)
    Display.show(statuses, debugInfo)
    sleep(10)
end
