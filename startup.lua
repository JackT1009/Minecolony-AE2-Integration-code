local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")

-- Load Modules
local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display")
local Exporter = require("modules/exporter")

-- Configure directions (WAREHOUSE ABOVE BRIDGE)
local WAREHOUSE_DIRECTION = "up"  -- Changed to "up"
local exporter = Exporter.new(bridge, WAREHOUSE_DIRECTION)

Display.initialize(monitor)
local checker = InventoryChecker.new(bridge)

-- Main Loop
while true do
    local requests = Colony.getRequests()
    local statuses, debugInfo = checker:getAllStatuses(requests)
    
    -- Auto-craft missing items with patterns
    for _, item in ipairs(statuses) do
        if item.status == "M" then
            local amountToCraft = item.needed - item.available
            
            -- Check if already crafting
            local isCrafting, craftErr = pcall(bridge.isItemCrafting, bridge, {name=item.name})
            if not isCrafting then
                -- Start new craft
                local success, err = pcall(bridge.craftItem, bridge, {
                    name = item.name,
                    count = amountToCraft
                })
                
                if success then
                    table.insert(debugInfo, "Crafting "..amountToCraft.."x "..item.name)
                else
                    table.insert(debugInfo, "Craft failed: "..err)
                end
            else
                table.insert(debugInfo, "Already crafting "..item.name)
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
