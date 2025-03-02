local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")

-- Load Modules
local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display")
local Exporter = require("modules/exporter")  -- Correct case-sensitive path

-- Configure directions (warehouse ABOVE bridge)
local WAREHOUSE_DIRECTION = "up"
local exporter = Exporter.new(bridge, WAREHOUSE_DIRECTION)

Display.initialize(monitor)
local checker = InventoryChecker.new(bridge)

-- Main Loop
while true do
    local requests = Colony.getRequests()
    local statuses, debugInfo = checker:getAllStatuses(requests)
    
    -- Auto-craft missing items
    for _, item in ipairs(statuses) do
        if item.status == "M" then
            local amountToCraft = item.needed - item.available
            local isCrafting, _ = pcall(bridge.isItemCrafting, bridge, {name=item.name})
            
            if not isCrafting then
                local success, err = pcall(bridge.craftItem, bridge, {
                    name = item.name,
                    count = amountToCraft
                })
                table.insert(debugInfo, success and 
                    "Crafting "..amountToCraft.."x "..item.name or 
                    "Craft failed: "..tostring(err))
            end
        end
    end
    
    -- Auto-export stocked items
    for _, item in ipairs(statuses) do
        if item.status == "/" then
            exporter:pushToWarehouse(item.name, item.needed)
        end
    end
    
    Display.show(statuses, debugInfo)
    sleep(10)
end
